library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package digit_array_pkg is
    -- Array of unsigned, each large enough to store 0 to 9
    type digit_array_t is array (natural range <>) of unsigned(4 downto 0);
end; 