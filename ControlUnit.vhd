LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY ControlUnit IS
	PORT (
		-- the whole instruction
		INSTRUCTION : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

		---------------- CONTROL SIGNALS ----------------

		-- Write Back Control
		WriteEnable : OUT STD_LOGIC;

		-- Memory Control
		MemRead  : OUT STD_LOGIC;
		MemWrite : OUT STD_LOGIC;
		MemFree  : OUT STD_LOGIC;
		MemProt  : OUT STD_LOGIC;

		-- Stack Control
		S_INC : OUT STD_LOGIC;
		S_DEC : OUT STD_LOGIC

	);
END ENTITY;

ARCHITECTURE a_ControlUnit OF ControlUnit IS
	BEGIN

		

END a_ControlUnit;