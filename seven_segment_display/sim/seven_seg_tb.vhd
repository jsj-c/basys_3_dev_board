library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.digit_array_pkg.all;

entity seven_seg_tb is
end entity;

architecture rtl of seven_seg_tb is

      constant clk_period : time := 10 ns;
    
      signal clk            : std_logic;
      
      signal digits_to_display : digit_array_t(3 downto 0);
    
      signal output         : std_logic_vector(6 downto 0);
      signal output_select  : std_logic_vector(3 downto 0);

begin
      clk_process: process is
      begin
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
    end process;

    digits_to_display(0) <= to_unsigned(0, digits_to_display(0)'length);
    digits_to_display(1) <= to_unsigned(1, digits_to_display(1)'length);
    digits_to_display(2) <= to_unsigned(2, digits_to_display(2)'length);
    digits_to_display(3) <= to_unsigned(3, digits_to_display(3)'length);
    
    uut : entity work.seven_seg_driver
    port map (
        clk      => clk,
        
        digits   => digits_to_display,
        
        segment  => output,
        selector => output_select
    );    

end architecture;