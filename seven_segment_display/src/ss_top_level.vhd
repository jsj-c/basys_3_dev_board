library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;
use work.digit_array_pkg.all;

entity top_ss_driver is
    Port (
        clk : in  std_logic;
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic_vector(3 downto 0)
    );
end top_ss_driver;

architecture rtl of top_ss_driver is

constant NUM_DIGITS_C : natural := 4;

signal digits_to_display : digit_array_t(NUM_DIGITS_C-1 downto 0);

begin

    digits_to_display(0) <= to_unsigned(0, digits_to_display(0)'length);
    digits_to_display(1) <= to_unsigned(1, digits_to_display(1)'length);
    digits_to_display(2) <= to_unsigned(2, digits_to_display(2)'length);
    digits_to_display(3) <= to_unsigned(3, digits_to_display(3)'length);

    four_way_seven_seg_driver_inst : entity work.seven_seg_driver
    generic map (
        NUM_DIGITS_G => NUM_DIGITS_C
    )
    port map (
        clk      => clk,

        digits   => digits_to_display,

        segment  => seg,
        selector => an
    );

end rtl;
