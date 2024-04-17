LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY OurALU IS
	PORT (
		Rsrc1: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rdst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	);
END OurALU;

ARCHITECTURE a_OurALU OF OurALU IS

	-------------------- MAIN COMPONENTS --------------------
	COMPONENT ALU_not IS
		PORT (
			Rsrc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_dec IS
		PORT (
			Rsrc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_or IS
		PORT (
			Rsrc1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_ldm IS
		PORT (
			Rsrc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_mov IS
		PORT (
			Rsrc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_cmp IS
		PORT (
			Rsrc1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;


	
	-- BUFFERING
	SIGNAL ALU_BUFFER_OUTPUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL ALU_NOT_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_DEC_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OR_OUT  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_LDM_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_MOV_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_CMP_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL ALU_MUXED_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);


	BEGIN

	u0: ALU_not PORT MAP(Rsrc1, ALU_NOT_OUT);
	u1: ALU_dec PORT MAP(Rsrc1, ALU_DEC_OUT);
	u2: ALU_or  PORT MAP(Rsrc1, Rsrc2, ALU_OR_OUT);
	u3: ALU_ldm PORT MAP(Rsrc1, ALU_LDM_OUT);
	u4: ALU_mov PORT MAP(Rsrc1, ALU_MOV_OUT);
	u5: ALU_cmp PORT MAP(Rsrc1, Rsrc2, ALU_CMP_OUT);

	-- TODO: Multiplex all the outputs

	-- Buffer The Output
	

		

END a_OurALU;