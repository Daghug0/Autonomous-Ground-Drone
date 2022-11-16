LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY CBS IS
END CBS;
ARCHITECTURE CBS_architecture OF CBS IS
-- Component declaration of the tested unit
COMPONENT Drone_Behaviour
PORT(
BP_Start_Stop: IN STD_LOGIC;
BP_Reset : IN STD_LOGIC;
Clock : IN STD_LOGIC;
SensRight : IN STD_LOGIC;
SensLeft : IN STD_LOGIC;
MotorRight_neg : OUT STD_LOGIC;
MotorRight_pos : OUT STD_LOGIC;
MotorLeft_neg : OUT STD_LOGIC;
MotorLeft_pos : OUT STD_LOGIC;
seg : out STD_LOGIC_VECTOR(6 DOWNTO 0);
an : out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;
-- Stimulus signals - signals mapped to the ports of tested entity
SIGNAL test_vector: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL test_result : STD_LOGIC;
SIGNAL clktest : std_logic :='0';
BEGIN
DUT : Drone_Behaviour
PORT MAP (
BP_Start_Stop => test_vector(0),
BP_Reset => test_vector(1),
SensRight => test_vector(2),
SensLeft => test_vector(3),
Clock => clktest
);
Testing: PROCESS
BEGIN
test_vector <= "0010";
WAIT FOR 20 ms;
test_vector <= "0000";
WAIT FOR 50 ms;
test_vector <= "0001";
WAIT FOR 20 ms;
test_vector <= "0000";
WAIT FOR 50 ms;
test_vector <= "1000";
WAIT FOR 20 ms;
test_vector <= "0000";
WAIT FOR 50 ms;
test_vector <= "0100";
WAIT FOR 20 ms;
test_vector <= "0000";
WAIT FOR 50 ms;
test_vector <= "1100";
WAIT FOR 50 ms;
test_vector <= "0000";
WAIT FOR 50 ms;
test_vector <= "0010";
WAIT FOR 20 ms;
test_vector <= "0000";
WAIT FOR 20 ms;
END PROCESS;
Clock10kHz :process
begin
clktest <= not(clktest);
WAIT FOR 5 ns;
end process;

END CBS_architecture;