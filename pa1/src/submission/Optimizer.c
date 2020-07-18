/*
 *********************************************
 *  314 Principles of Programming Languages  *
 *  Spring 2014                              *
 *  Authors: Ulrich Kremer                   *
 *           Hans Christian Woithe           *
 *********************************************
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "InstrUtils.h"
#include "Utils.h"

int findNumOfRegs(Instruction*);

void markW(Instruction*);
void findStore(Instruction*, int);
void regHunt(Instruction*, int);

void eliminate(Instruction*);

int main()
{
	Instruction *head;
	


	head = ReadInstructionList(stdin);
	if (!head) {
		WARNING("No instructions\n");
		exit(EXIT_FAILURE);
	}
	/* YOUR CODE GOES HERE */
	//temp = findNumOfRegs(head);

	//printf("peepee\n");
	markW(head);
	//printf("Marking complete\n");

	eliminate(head);
	//printf("Eliminate attempted... PSYCH\n");
	if (head) {
		PrintInstructionList(stdout, head);
		DestroyInstructionList(head);
	}
	return EXIT_SUCCESS;
}


int findNumOfRegs(Instruction *head){
	
	int numRegs = 0;
	Instruction* ptr;
	ptr = head;
	//ptr = ptr->next;

	while(ptr != NULL){
		//Get the specific opcode
		switch(ptr->opcode){
			/*break switch into cases for each opcode and respective register*/
			case LOADI:
			if((ptr->field1 != 0)){
				numRegs++;
				//printf("read a LOADI\n");
				break;
			}
			case LOAD:
			if((ptr->field1 != 0)){
				numRegs++;
				//printf("Read a LOAD\n");
				break;
			}
			//store wouldnt be used to make new registers
			/*
			case STORE:
			if((ptr->field2 != 0)){
				numRegs++;
				printf("read a STORE\n");
				break;
			}
			*/
			/*any new register called in arithmetic instructions
			will be in the first field*/
			case ADD:
			case SUB:
			case MUL:
			if((ptr->field1 != 0)){
				numRegs++;
				//printf("Read an ADD/SUB/MUL\n");
				break;
			}
			case AND:
			case OR:
			if((ptr->field1 != 0)){
				numRegs++;
				//printf("Read an AND/OR\n");
				break;
			}
			case READ:
			case WRITE:
				//printf("Read a WRITE\n");
				break;
			
			default:
				ERROR("Illegal Instructions\n");
		}

		ptr = ptr->next;
	}

	return numRegs;


}


void markW(Instruction *head){
	
	Instruction *tail;
	tail = LastInstruction(head);

	while(tail != NULL){
		switch(tail->opcode){
			case WRITE:
			tail->critical = '1';

			//find store
			/* if we ahve a write, we can traceback to find the associated
			STORE instruction with it
			*/
			/*this will call the store method looking for the matching
			variable of this 'write'*/
			//printf("finding store\n");
			findStore(tail, tail->field1);
			break;

			case READ:
			tail->critical = '1';
			break;

			default:
			//printf("All WRITES marked\n");
			break;
		}
		//cause we're iterating backwards
		tail = tail->prev;

	}

//sanshodatale

}
void findStore(Instruction *ptr, int var){
	//Make sure we're not pointing to the same instruction
	ptr = ptr->prev;
	while(ptr != NULL){
		/*ptr field 1 (variable) matches up*/
		if(ptr->field1 == var){
			ptr->critical = '1';
			//ptr points to the store instruction
			//printf("starting regHunt for %d\n", var);
			//printf("ptr->field2 is equal to %d\n", ptr->field2);
			//ptr = ptr->prev;
			regHunt(ptr->prev, ptr->field2);
			
			//printf("reghunt attempted\n");
			
			break;

		}
		ptr = ptr->prev;
	}
	//printf("Stored has been marked\n");
}
void regHunt(Instruction *ptr, int reg){
	/*we now have the register we are looking for, we just have to recurse back
	and mark off any critical instructions that have the same field2 or field3.
	*/
	//could try with cases??

	while(ptr != NULL){
		switch(ptr->opcode){
			case LOADI:
			if(ptr->field1 == reg){

				ptr->critical = '1';
				return;
			}else{
				//printf("loadi case returning\n");
				break;
			}
			break;
			case MUL:
			case SUB:
			case ADD:
			case AND:
			case OR:
			
			if(ptr->field1 == reg){
				ptr->critical = '1';
				//printf("REGHUNT bABY\n");
				//make it recursive? call the same method on the next two registers
				regHunt(ptr->prev, ptr->field2);
				regHunt(ptr->prev, ptr->field3);
				//ptr = ptr->prev;
			}
			break;
			case LOAD:
			if(ptr->field1 == reg){
				ptr->critical = '1';
				//printf("load case\n");
				regHunt(ptr->prev, ptr->field2);

			}
			break;
			case STORE:
			if(ptr->field1 == reg){
				ptr->critical = '1';
				regHunt(ptr->prev, ptr->field2);
			}
			break;
		}
		//printf("peepoopoo\n");
		ptr = ptr->prev;
	}

}

void eliminate(Instruction *head){
	//go through the doubly LL and delete all nodes who's critical field is 1
	Instruction *ptr, *temp;
	ptr = head;
	//start from the start of the instructions list
	//printf("Starting elimination\n");
	while(ptr != NULL){
if(ptr->critical != '1'){
	//printf("Passed critical check\n");
    if(ptr->prev != NULL){
      ptr->prev->next = ptr->next;
    }
    if(ptr->next != NULL){
      ptr->next->prev = ptr->prev;
    }
    temp = ptr;
	ptr = ptr->next;
    free(temp);
  }else{
	ptr = ptr->next;
  }
 
}
}
