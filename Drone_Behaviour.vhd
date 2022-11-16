----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.10.2022 15:09:07
-- Design Name: 
-- Module Name: Drone_Behaviour - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Drone_Behaviour is
    Port ( BP_Start_Stop : in STD_LOGIC;
           BP_Reset : in STD_LOGIC;
           Clock : in STD_LOGIC;
           SensRight : in STD_LOGIC;
           SensLeft : in STD_LOGIC;
           MotorRight_pos : out STD_LOGIC;
           MotorRight_neg : out STD_LOGIC;
           MotorLeft_pos : out STD_LOGIC;
           MotorLeft_neg : out STD_LOGIC;
           seg : out STD_LOGIC_VECTOR(6 DOWNTO 0);
           an : out STD_LOGIC_VECTOR(3 DOWNTO 0)
           );
           
end Drone_Behaviour;

architecture Behavioral of Drone_Behaviour is
type state is (A0,A1,M0,M1); -- define the state type
signal pr_state, nx_state : state; -- declare present state and next state
signal Move : std_logic;
signal PWMcnt : integer range 0 to 99 := 0;
signal rhythm_5kHz :std_logic;
signal rhythm_1kHz :std_logic;
signal counter_5k : integer range 0 to 19999 := 0;
signal counter_1k : integer range 0 to 99999 := 0;
signal display_cnt : integer range 0 to 3 := 0;
signal PWM_L,PWM_M,PWM_H : std_logic;
type speed is (S,L,M,H);
signal MotorLeftSpeed,MotorRightSpeed : speed;

constant MAX_COUNT : integer := 19999;
constant number_0 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000000" ;
constant number_1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111100";
constant number_5 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010010";
constant number_9 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010000";
begin
--State machine for control Bloc
    --section 1 step : Register
    process (BP_Reset,Clock)
        begin
            if (BP_Reset='1') then
                pr_state <= A0; -- choose reset state
            elsif (clock'event and Clock='1') then
                pr_state <= nx_state;
            end if;
    end process;
    -- section 2: next state function
    process (BP_Start_Stop, pr_state)
        begin
            case pr_state is
            when A0 =>
                if (BP_Start_Stop = '0' ) then
                    nx_state <= A0;
                else
                    nx_state <= M0;
                end if;
                
             when M0 =>
                if (BP_Start_Stop = '1' ) then
                    nx_state <= M0;
                else
                    nx_state <= M1;
                end if;
                
           when M1 =>
                if (BP_Start_Stop = '0' ) then
                    nx_state <= M1;
                else
                    nx_state <= A1;
                end if;
                
             when A1 =>
                if (BP_Start_Stop = '1' ) then
                    nx_state <= A1;
                else
                    nx_state <= A0;
                end if;     
            end case;
        end process;
     -- section 3: output logic  
Move <= '1' when pr_state = M0 or pr_state = M1 else '0';

--Motor Speed Bloc
--create the rhythm
process(Clock)
    begin
        if rising_edge(Clock) then
            counter_5k <= counter_5k + 1;
            if (rhythm_5kHz <= '1') then
            rhythm_5kHz <= '0';
            end if;
            if (counter_5k >= MAX_COUNT) then
                counter_5k <= 0;
                rhythm_5kHz <= '1';
            end if;
        end if;
    end process;
 process(rhythm_5kHz, Clock)
    begin
        if rising_edge(clock) and (rhythm_5kHz = '1') then
            PWMcnt <= PWMcnt+1;
        end if;
        if (PWMcnt >= 99) then
            PWMcnt <= 0;
        end if;
      end process;
process(PWMcnt)
    begin
        if PWMcnt = 0 then
            PWM_L <= '1';
            PWM_M <= '1';
            PWM_H <= '1';
        end if;
        if PWMcnt = 15 then
            PWM_L <= '0';
        elsif PWMcnt = 50 then
            PWM_M <= '0';
        elsif PWMcnt = 95 then
            PWM_H <= '0';
        end if;
end process;
--Multiplexer for Direction bloc
Multiplexer : process (Move, PWM_L, PWM_M, PWM_H, SensRight, SensLeft)
begin
if (Move = '0') then 
    MotorRight_pos <= '0';
    MotorLeft_pos <= '0';
    MotorRightSpeed <= S;
    MotorLeftSpeed <= S; 
elsif (Move = '1') then
    if (SensRight = '0' and SensLeft = '0') then
        MotorRight_pos <= PWM_H;
        MotorLeft_pos <= PWM_H;
        MotorRightSpeed <= H;
        MotorLeftSpeed <= H;
    elsif (SensRight = '1' and SensLeft = '0') then  
        MotorRight_pos <= PWM_L;
        MotorLeft_pos <= PWM_M;
        MotorRightSpeed <= L;
        MotorLeftSpeed <= M;
    elsif (SensRight = '0' and SensLeft = '1') then  
        MotorRight_pos <= PWM_M;
        MotorLeft_pos <= PWM_L;
        MotorRightSpeed <= M;
        MotorLeftSpeed <= L;
     elsif (SensRight = '1' and SensLeft = '1') then  
        MotorRight_pos <= '0';
        MotorLeft_pos <= '0';
        MotorRightSpeed <= S;
        MotorLeftSpeed <= S;
        end if;
end if;
end process Multiplexer ;

process(Clock)
    begin
        if rising_edge(Clock) then
            counter_1k <= counter_1k + 1;
            if (rhythm_1kHz <= '1') then
            rhythm_1kHz <= '0';
            end if;
            if (counter_1k >= 99999) then
                counter_1k <= 0;
                rhythm_1kHz <= '1';
            end if;
        end if;
 end process;
 
process(rhythm_1kHz,Clock)
    begin
        if rising_edge(Clock) and (rhythm_1kHz = '1') then
            if (display_cnt < 3) then
                display_cnt <= display_cnt+1;
            else display_cnt <= 0;
            end if ;         
        end if;
    end process;

LCD_multiplexer : process(MotorLeftSpeed,MotorRightSpeed,display_cnt)
    begin
        if (display_cnt = 0) then
            an <= "0111";
            case MotorLeftSpeed is
                when S =>
                    seg <= number_0; --0
                when L =>
                    seg <= number_1; --1
                when M =>
                    seg <= number_5; --5 
                when H =>
                    seg <= number_9; --9 
            end case;
        elsif (display_cnt = 1) then
            an <= "1011";
            case MotorLeftSpeed is
                when S =>
                     seg <= number_0; --0
                when L =>
                     seg <= number_5; --5 
                when M =>
                     seg <= number_0; --0
                when H =>
                    seg <= number_5; --5 
            end case;
        elsif (display_cnt = 2) then
            an <= "1101";
            case MotorRightSpeed is
                when S =>
                    seg <= number_0; --0
                when L =>
                    seg <= number_1; --1
                when M =>
                    seg <= number_5; --5 
                when H =>
                    seg <= number_9; --9 
            end case;  
         elsif (display_cnt = 3) then
            an <= "1110";
            case MotorRightSpeed is
                when S =>
                     seg <= number_0; --0
                when L =>
                     seg <= number_5; --5
                when M =>
                     seg <= number_0; --0
                when H =>
                    seg <= number_5; --5
            end case;
         end if;
    end process LCD_multiplexer;        
end Behavioral;
