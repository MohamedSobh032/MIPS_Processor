LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MIPS_Processor IS
	PORT (
		CLK     : IN  STD_LOGIC;
		RST     : IN  STD_LOGIC;
		INPORT  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OUTPORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R0      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R1      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R2      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R3      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R4      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R5      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R6      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R7      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		FLAGS   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END MIPS_Processor;

ARCHITECTURE a_MIPS_Processor OF MIPS_Processor IS

	-- SIDE COMPONENTS --
	COMPONENT SignExtender IS
		PORT (
			input_16  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        	   	output_32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	-- MAIN COMPONENTS -- 
	COMPONENT PCount IS
		PORT (
			CLK      : IN  STD_LOGIC;
			RST      : IN  STD_LOGIC;
			ResetVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			NewValue : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Outdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT InstrCache IS
		PORT (
			CLK          : IN  STD_LOGIC;
			Addr         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
			ResetAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			Instruction  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT FetchDecode IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			FLUSH : IN STD_LOGIC;
			InData_Instruction  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			OutData_Instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			InData_NextPC  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT registerfile IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE1       : IN STD_LOGIC;
			Rdst1     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE2       : IN STD_LOGIC;
			Rdst2     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			R0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ControlUnit IS
		PORT (
			INSTRUCTION : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			CONTROL_SIGNALS : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			ALU_OPCODE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT DecodeExecute IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			InData_NextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_ConSignal  : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			InData_ALUopCode  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			OutData_ALUopCode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			InData_Rsrc1Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rsrc2Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT OurALU IS
		PORT (
			CLK: IN STD_LOGIC;
			OPERATION: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			OP1, OP2: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			RESULT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FLAGS: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ExecuteMemory IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			InData_NextPC     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_ConSignal  : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			InData_ALUresult  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_ALUresult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT StackPointer IS
		PORT (
			CLK       : IN STD_LOGIC;
			RST       : IN STD_LOGIC;
			SP_INC    : IN STD_LOGIC;
			SP_DEC    : IN STD_LOGIC;
			SP_OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT memor IS
		PORT (
			CLK : IN STD_LOGIC;
	    		RST : IN STD_LOGIC;
			Addr  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    			MemRead   : IN STD_LOGIC;
    			ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			MemWrite  : IN STD_LOGIC;
    			WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			free_i : IN STD_LOGIC;
			prot_i : IN STD_LOGIC
	    	);
	END COMPONENT;
	COMPONENT MemoryWriteback IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			InData_ConSignal  : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			InData_MemData  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_MemData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
	END COMPONENT;
	COMPONENT OutReg IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			OutEnable : IN STD_LOGIC;
			Data_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutputPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT CCR IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			ZNF : IN STD_LOGIC;
			OVCF : IN STD_LOGIC;
			FlagIn: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			FlagOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------

	----------------------------------------- FETCH SIGNALS -----------------------------------------
	SIGNAL PC                : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RESET_ADDRESS     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL NewPC             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrInstr_FROM_IC : STD_LOGIC_VECTOR(15 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- DECODE SIGNALS ----------------------------------------
	-- F/D REGISTER OUTPUTS
	SIGNAL CurrentInstr_FROM_FDP         : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_FDP         : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL NextPC_FROM_FDP	             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- DIVIDE F/D VALUES
	SIGNAL Rsrc1Addr_DIV_CurrInstr       : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Addr_DIV_CurrInstr       : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL RdstAddr_DIV_CurrInstr        : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL OpCode_DIV_CurrInstr          : STD_LOGIC_VECTOR(4 DOWNTO 0);
	-- REGISTER FILE OUTPUTS
	SIGNAL Rsrc1Data_FROM_RF             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_RF             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- CONTROL UNIT OUTPUTS
	SIGNAL SIGNALS_FROM_CONTROL          : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL ALUopCode_FROM_CONTROL        : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL Rdst1Addr_FROM_MUXING         : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND_0    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND_SIGN : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_MUXING         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- EXECUTE SIGNALS ---------------------------------------
	-- D/E REGISTER OUTPUTS
	SIGNAL NextPC_FROM_DEP      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_DEP     : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL ALUopCode_FROM_DEP   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc1Data_FROM_DEP   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_DEP   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_DEP   : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_DEP   : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- ALU OUTPUTS
	SIGNAL ALUresult_FROM_ALU   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUflag_FROM_ALU     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL DATA_OUT_FROM_MUXING : STD_LOGIC_VECTOR(31 DOWNTO 0); -- MULTIPLEX BETWEEN ALU AND INPORT
	-------------------------------------------------------------------------------------------------

	------------------------------------------ MEMORY SIGNALS ---------------------------------------
	-- E/M REGISTER OUTPUTS
	SIGNAL NextPC_FROM_EMP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_EMP    : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL ALUresult_FROM_EMP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_EMP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_EMP  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_EMP  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL SP_FROM_STACK       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ADDRESS_SELECTOR    : STD_LOGIC;
	SIGNAL ADDRESS_FROM_MUXING : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL DATA_FROM_MUXING_1  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_FROM_MUXING    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_FROM_MEMORY    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- WRITEBACK SIGNALS -------------------------------------
	-- M/W REGISTER OUTPUTS
	SIGNAL SIGNALS_FROM_MWP   : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL Rdst1Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	BEGIN
		
		------------------------------------------ FETCH STAGE ------------------------------------------
		u00: PCount PORT MAP(CLK, RST, RESET_ADDRESS, NewPC, PC);
		u02: InstrCache PORT MAP(CLK, PC(11 DOWNTO 0), RESET_ADDRESS, CurrInstr_FROM_IC);
		NewPc <= std_logic_vector(unsigned(PC) + 1);
		-------------------------------------------------------------------------------------------------

		------------------------------------ FETCH / DECODE PIPELINE ------------------------------------
		u10: FetchDecode PORT MAP(CLK, RST, SIGNALS_FROM_CONTROL(8), CurrInstr_FROM_IC,
				CurrentInstr_FROM_FDP, NewPC, NextPC_FROM_FDP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ DECODE STAGE -----------------------------------------
		OpCode_DIV_CurrInstr    <= CurrentInstr_FROM_FDP(15 DOWNTO 11);
		RdstAddr_DIV_CurrInstr  <= CurrentInstr_FROM_FDP(10 DOWNTO  8);
		Rsrc1Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(7  DOWNTO  5);
		Rsrc2Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(4  DOWNTO  2);

		u20: registerfile PORT MAP(CLK, RST, Rsrc1Addr_DIV_CurrInstr, Rsrc2Addr_DIV_CurrInstr,
					Rsrc1Data_FROM_RF, Rsrc2Data_FROM_RF,
						SIGNALS_FROM_MWP(0), Rdst1Addr_FROM_MWP, Rdst1Data_FROM_MWP,
						SIGNALS_FROM_MWP(1), Rdst2Addr_FROM_MWP, Rdst2Data_FROM_MWP,
						R0, R1, R2, R3, R4, R5, R6, R7);

		u21: ControlUnit PORT MAP(OpCode_DIV_CurrInstr, SIGNALS_FROM_CONTROL,
						ALUopCode_FROM_CONTROL);

		Rdst1Addr_FROM_MUXING <= RdstAddr_DIV_CurrInstr WHEN (SIGNALS_FROM_CONTROL(1) = '0')
		ELSE Rsrc2Addr_DIV_CurrInstr;

		u22: SignExtender PORT MAP(CurrInstr_FROM_IC, ImmediateVal_FROM_EXTEND_SIGN);
		ImmediateVal_FROM_EXTEND_0 <= x"0000" & CurrInstr_FROM_IC;

		ImmediateVal_FROM_EXTEND <= ImmediateVal_FROM_EXTEND_0 WHEN (SIGNALS_FROM_CONTROL(17) = '1')
				ELSE ImmediateVal_FROM_EXTEND_SIGN;
		
		Rsrc2Data_FROM_MUXING <= ImmediateVal_FROM_EXTEND WHEN (SIGNALS_FROM_CONTROL(8) = '1')
			ELSE Rsrc2Data_FROM_RF;
		-------------------------------------------------------------------------------------------------

		----------------------------------- DECODE / EXECUTE PIPELINE -----------------------------------
		u30: DecodeExecute PORT MAP(CLK, RST, NextPC_FROM_FDP, NextPC_FROM_DEP,
					SIGNALS_FROM_CONTROL, SIGNALS_FROM_DEP,
					ALUopCode_FROM_CONTROL, ALUopCode_FROM_DEP,
					Rsrc1Data_FROM_RF, Rsrc1Data_FROM_DEP,
					Rsrc2Data_FROM_MUXING, Rsrc2Data_FROM_DEP,
					Rdst1Addr_FROM_MUXING, Rdst1Addr_FROM_DEP,
					Rsrc1Addr_DIV_CurrInstr, Rdst2Addr_FROM_DEP);
		-------------------------------------------------------------------------------------------------

		----------------------------------------- EXECUTE STAGE -----------------------------------------
		u41: OurALU PORT MAP(CLK, ALUopCode_FROM_DEP, Rsrc1Data_FROM_DEP, Rsrc2Data_FROM_DEP,
					ALUresult_FROM_ALU, ALUflag_FROM_ALU);

		u42: CCR PORT MAP(CLK, RST, SIGNALS_FROM_DEP(2), SIGNALS_FROM_DEP(3), ALUflag_FROM_ALU, FLAGS);

		u43: OutReg PORT MAP(CLK, RST, SIGNALS_FROM_DEP(13), Rsrc1Data_FROM_DEP, OUTPORT);

		DATA_OUT_FROM_MUXING <= ALUresult_FROM_ALU WHEN (SIGNALS_FROM_DEP(14) = '0') ELSE INPORT;
		-------------------------------------------------------------------------------------------------
	
		----------------------------------- EXECUTE / MEMORY PIPELINE -----------------------------------
		u50: ExecuteMemory PORT MAP(CLK, RST, NextPC_FROM_DEP, NextPC_FROM_EMP,
				SIGNALS_FROM_DEP, SIGNALS_FROM_EMP, DATA_OUT_FROM_MUXING,
				ALUresult_FROM_EMP, Rsrc2Data_FROM_DEP, Rdst2Data_FROM_EMP,
				Rdst1Addr_FROM_DEP, Rdst1Addr_FROM_EMP, Rdst2Addr_FROM_DEP,
						Rdst2Addr_FROM_EMP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ MEMORY STAGE -----------------------------------------
		u60: StackPointer PORT MAP(CLK, RST, SIGNALS_FROM_DEP(12),
				SIGNALS_FROM_DEP(11), SP_FROM_STACK);

		DATA_FROM_MUXING_1 <= ALUresult_FROM_EMP WHEN (SIGNALS_FROM_EMP(15) = '0')
		ELSE Rdst2Data_FROM_EMP;

		DATA_FROM_MUXING <= DATA_FROM_MUXING_1 WHEN (SIGNALS_FROM_EMP(16) = '0')
		ELSE NextPC_FROM_EMP;

		ADDRESS_FROM_MUXING <= ALUresult_FROM_EMP(11 DOWNTO 0)
				WHEN (SIGNALS_FROM_EMP(11) = '0' and SIGNALS_FROM_EMP(11) = '0') ELSE
		SP_FROM_STACK(11 DOWNTO 0);

		u61: memor PORT MAP(CLK, RST, ADDRESS_FROM_MUXING, SIGNALS_FROM_EMP(4),
					DATA_FROM_MEMORY, SIGNALS_FROM_EMP(5),
					DATA_FROM_MUXING, SIGNALS_FROM_EMP(6), SIGNALS_FROM_EMP(7));
		-------------------------------------------------------------------------------------------------

		---------------------------------- MEMORY / WRITEBACK PIPELINE ----------------------------------
		u70: MemoryWriteback PORT MAP(CLK, RST, SIGNALS_FROM_EMP, SIGNALS_FROM_MWP,
				DATA_FROM_MEMORY, Rdst1Data_FROM_MWP, Rdst2Data_FROM_EMP, Rdst2Data_FROM_MWP,
				Rdst1Addr_FROM_EMP, Rdst1Addr_FROM_MWP, Rdst2Addr_FROM_EMP, Rdst2Addr_FROM_MWP);
		-------------------------------------------------------------------------------------------------

END a_MIPS_Processor;