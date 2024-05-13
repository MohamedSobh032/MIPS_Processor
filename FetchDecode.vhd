LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FetchDecode IS
	PORT (
		CLK   : IN STD_LOGIC;
		RST   : IN STD_LOGIC;
		FLUSH : IN STD_LOGIC;

		InData_Instruction  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		OutData_Instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

		InData_NextPC  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_NextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END FetchDecode;

ARCHITECTURE a_FetchDecode OF FetchDecode IS

	-- REGISTER --
    	SIGNAL Instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL NextPC : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				Instruction <= (OTHERS => '0');
				NextPC      <= (OTHERS => '0');
			ELSIF falling_edge(CLK) THEN
				IF (FLUSH = '1') THEN
					Instruction <= (OTHERS => '0');
					NextPC      <= (OTHERS => '0');
				ELSE
					Instruction <= InData_Instruction;
					NextPC      <= InData_NextPC;
				END IF;
			END IF;
		END PROCESS;	
		OutData_Instruction <= Instruction;
		OutData_NextPC      <= NextPC;
END a_FetchDecode;