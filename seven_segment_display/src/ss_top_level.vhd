library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

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

constant NUM_DIGITS_C           : natural := 4;
constant CLK_FREQUENCY_MHZ_C    : natural := 100;
constant CLKS_IN_SECOND_C       : natural := CLK_FREQUENCY_MHZ_C * 1000000;
constant SECOND_COUNTER_WIDTH_C : natural := integer(ceil(log2(real(CLKS_IN_SECOND_C))));

signal digits_to_display     : digit_array_t(NUM_DIGITS_C-1 downto 0) := (others => (others => '0'));
signal digits_to_display_reg : digit_array_t(NUM_DIGITS_C-1 downto 0) := (others => (others => '0'));

signal second_counter : unsigned(SECOND_COUNTER_WIDTH_C downto 0);

begin

    second_counter_proc : process(clk) is
    begin
        if rising_edge(clk) then
            second_counter <= second_counter + 1;
            if (second_counter = CLKS_IN_SECOND_C) then
                second_counter <= (others => '0');
            end if;
        end if;
    end process;

    first_display_proc : process(clk) is
    begin
        if rising_edge(clk) then
            digits_to_display_reg <= digits_to_display;
            if (second_counter = CLKS_IN_SECOND_C) then
                digits_to_display(0) <= digits_to_display(0) + 1;
                if (digits_to_display(0) = 9) then
                    digits_to_display(0) <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    extra_display_gen : for i in 1 to NUM_DIGITS_C-1 generate
        extra_display_proc : process(clk) is
        begin
            if rising_edge(clk) then
                if (digits_to_display_reg(i-1) /= 0) and (digits_to_display(i-1) = 0) then
                    digits_to_display(i) <= digits_to_display(i) + 1;
                    if (digits_to_display(i) = 9) then
                        digits_to_display(i) <= (others => '0');
                    end if;
                end if;
            end if;
        end process;
    end generate;

    four_way_seven_seg_driver_inst : entity work.seven_seg_driver
    generic map (
        NUM_DIGITS_G             => NUM_DIGITS_C,
        REFRESH_MILLISECONDS_G   => 16,
        CLK_PERIOD_NANOSECONDS_G => 10
    )
    port map (
        clk      => clk,

        digits   => digits_to_display,

        segment  => seg,
        selector => an
    );

end rtl;
