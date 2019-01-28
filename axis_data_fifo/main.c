// Author: Erwin Ouyang
// Date  : 24 Jan 2019

#include <stdio.h>
#include "xparameters.h"
#include "xllfifo.h"
#include "xstatus.h"

#define FIFO_DEVICE_ID			XPAR_AXI_FIFO_0_DEVICE_ID
#define WORD_SIZE 				4    // Size of a word in bytes
#define MAX_PACKET_LEN 			6
#define NO_OF_PACKETS 			8
#define MAX_DATA_BUFFER_SIZE	NO_OF_PACKETS * MAX_PACKET_LEN

XLlFifo FifoInstance;
uint32_t SrcBuffer[MAX_DATA_BUFFER_SIZE];
uint32_t DstBuffer[MAX_DATA_BUFFER_SIZE];

int FifoInit(XLlFifo *InstancePtr, uint16_t DeviceId);
int FifoTest(XLlFifo *InstancePtr, uint16_t DeviceId);
int FifoSend(XLlFifo *InstancePtr, uint32_t *SrcAddr);
int FifoRecv(XLlFifo *InstancePtr, uint32_t *DstAddr);

int main()
{
	if (FifoInit(&FifoInstance, FIFO_DEVICE_ID) != XST_SUCCESS)
		printf("AXI-Stream FIFO initialization failed!\n");
	else
		printf("AXI-Stream FIFO initialization passed!\n");

	if (FifoTest(&FifoInstance, FIFO_DEVICE_ID) != XST_SUCCESS)
		printf("AXI-Stream FIFO polling test failed!\n");
	else
		printf("AXI-Stream FIFO polling test passed!\n");

    return 0;
}

int FifoInit(XLlFifo *InstancePtr, uint16_t DeviceId)
{
	XLlFifo_Config *Config;
	int Status = XST_SUCCESS;

	// *** Initialize FIFO ***
	Config = XLlFfio_LookupConfig(DeviceId);
	if (!Config)
	{
		printf("No configuration found for %d\n", DeviceId);
		return XST_FAILURE;
	}
	Status = XLlFifo_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS)
	{
		printf("Initialization failed\n");
		return Status;
	}

	// *** Check for the reset value ***
	Status = XLlFifo_Status(InstancePtr);
	XLlFifo_IntClear(InstancePtr, 0xFFFFFFFF);
	Status = XLlFifo_Status(InstancePtr);
	if (Status != 0)
	{
		printf("ERROR: Reset value of ISR0: 0x%x\tExpected: 0x0\n",
			    (unsigned int)XLlFifo_Status(InstancePtr));
		return XST_FAILURE;
	}

	return Status;
}

int FifoTest(XLlFifo *InstancePtr, uint16_t DeviceId)
{
	int Status = XST_SUCCESS;

	// *** Transmit the data ***
	Status = FifoSend(InstancePtr, SrcBuffer);
	if (Status != XST_SUCCESS)
	{
		printf("Transmission of data failed\n");
		return XST_FAILURE;
	}

	// *** Print the transmitted data ***
	for (int i = 0; i < MAX_DATA_BUFFER_SIZE; i++)
		printf("%d | ", (unsigned int)SrcBuffer[i]);
	printf("\n");

	// *** Receive the data ***
	Status = FifoRecv(InstancePtr, DstBuffer);
	if (Status != XST_SUCCESS)
	{
		printf("Receiving data failed\n");
		return XST_FAILURE;
	}

	// *** Print the received data ***
	for (int i = 0; i < MAX_DATA_BUFFER_SIZE; i++)
		printf("%d | ", (unsigned int)DstBuffer[i]);
	printf("\n");

	// *** Compare the transmitted and received data ***
	printf("Comparing data ...\n");
	for (int i = 0; i < MAX_DATA_BUFFER_SIZE; i++)
		if (SrcBuffer[i] != DstBuffer[i])
			return XST_FAILURE;

	return Status;
}

int FifoSend(XLlFifo *InstancePtr, uint32_t *SrcAddr)
{
	printf("Transmitting data ... \n");

	// *** Filling the source buffer with data ***
	for (int i = 0; i < MAX_DATA_BUFFER_SIZE; i++)
		SrcAddr[i] = i;

	// *** Writing the source buffer into the FIFO transmit buffer ***
	for (int i = 0; i < NO_OF_PACKETS; i++)
		for (int j = 0; j < MAX_PACKET_LEN; j++)
			if(XLlFifo_iTxVacancy(InstancePtr))
				XLlFifo_TxPutWord(InstancePtr, SrcAddr[(i * MAX_PACKET_LEN) + j]);

	// Start transmission by writing transmission length (in bytes) into the TLR
	XLlFifo_iTxSetLen(InstancePtr, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));

	// Check for transmission completion
	while (!(XLlFifo_IsTxDone(InstancePtr)));

	return XST_SUCCESS;
}

int FifoRecv(XLlFifo *InstancePtr, uint32_t *DstAddr)
{
	int RecvLen = 0;
	int RecvWord = 0;
	int Status = TRUE;

	printf("Receiving data ...\n");

	// *** Read receive length ***
	RecvLen = XLlFifo_iRxGetLen(InstancePtr) / WORD_SIZE;

	// *** Read the data from FIFO receive buffer ***
	for (int i = 0; i < RecvLen; i++)
	{
		RecvWord = XLlFifo_RxGetWord(InstancePtr);
		if (XLlFifo_iRxOccupancy(InstancePtr))
			RecvWord = XLlFifo_RxGetWord(InstancePtr);
		DstAddr[i] = RecvWord;
	}

	// *** Check for receive completion ***
	Status = XLlFifo_IsRxDone(InstancePtr);
	if (Status != TRUE)
	{
		printf("Failing in receive complete ...\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
