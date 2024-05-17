use work.digit_array_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        NUM_DIGITS_G : natural := 4
    );
    Port (
        -- Control
        clk : in  std_logic;

        -- Inputs
        digits : in digit_array_t(NUM_DIGITS_G-1 downto 0);

        -- Outputs
        segment  : out std_logic_vector(6 downto 0);
        selector : out std_logic_vector(NUM_DIGITS_G-1 downto 0)
    );
end seven_seg_driver;

architecture rtl of seven_seg_driver is

type digit_lut_t is array (0 to 9) of std_logic_vector(6 downto 0);
constant digit_lut : digit_lut_t :=
  (0 => ("1000000"),
   1 => ("1111001"),
   2 => ("0100100"),
   3 => ("0110000"),
   4 => ("0011001"),
   5 => ("0010010"),
   6 => ("0000010"),
   7 => ("1111000"),
   8 => ("0000000"),
   9 => ("0010000")
  );

constant REFRESH_MILLISECONDS_C    : natural := 4;
constant CLK_PERIOD_NANOSECONDS_C  : natural := 10;
constant REFRESH_CLKS_C            : natural := REFRESH_MILLISECONDS_C * 1000000 / CLK_PERIOD_NANOSECONDS_C;

constant COUNTER_WIDTH_C           : natural := integer(ceil(log2(real(REFRESH_CLKS_C))));
constant DISPLAY_SELECTOR_WIDTH_C  : natural := integer(ceil(log2(real(NUM_DIGITS_G))));

signal refresh_counter  : unsigned(COUNTER_WIDTH_C downto 0)          := (others => '0');
signal display_selector : unsigned(DISPLAY_SELECTOR_WIDTH_C downto 0) := (others => '0');

begin

    refresh_counter_proc : process(clk) is
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter = REFRESH_CLKS_C) then
                refresh_counter <= (others => '0');
            end if;
        end if;
    end process;

    display_selector_proc : process(clk) is
    begin
        if rising_edge(clk) then
            selector <= (others => '1');
            selector(to_integer(display_selector)) <= '0';
            if (refresh_counter = REFRESH_CLKS_C) then
                display_selector <= display_selector + 1;
                if (display_selector = NUM_DIGITS_G-1) then
                    display_selector <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    display_driver_proc : process(clk) is
    begin
        if rising_edge(clk) then
            segment <= digit_lut(to_integer(digits(to_integer(display_selector))));
        end if;
    end process;
end rtl;



