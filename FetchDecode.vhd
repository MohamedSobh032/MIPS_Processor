LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FetchDecode IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		NewValue : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		Outdata  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END FetchDecode;

ARCHITECTURE a_FetchDecode OF FetchDecode IS
    	SIGNAL FetchDecode : STD_LOGIC_VECTOR(15 DOWNTO 0);
	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				FetchDecode <= (OTHERS => '0');
			ELSIF falling_edge(CLK) THEN
				FetchDecode <= NewValue;
			END IF;
		END PROCESS;	
		OutData <= FetchDecode;
END a_FetchDecode;