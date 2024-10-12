library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top_vga_driver is
    Port (
        clk : in std_logic;

        sw   : in std_logic_vector(15 downto 0);
        btnC : in std_logic;

        vgaRed   : out std_logic_vector(3 downto 0);
        vgaGreen : out std_logic_vector(3 downto 0);
        vgaBlue  : out std_logic_vector(3 downto 0);
        Hsync    : out std_logic;
        Vsync    : out std_logic
    );
end top_vga_driver;

architecture rtl of top_vga_driver is

CONSTANT H_LIMIT    : natural := 800;
CONSTANT H_RES      : natural := 640;
CONSTANT H_L_BORDER : natural := 148;
CONSTANT H_R_BORDER : natural := 12;

CONSTANT V_LIMIT    : natural := 525;
CONSTANT V_RES      : natural := 480;
CONSTANT V_T_BORDER : natural := 35;
CONSTANT V_B_BORDER : natural := 10;

signal reset : std_logic;

signal pixel_clk        : std_logic;
signal pixel_clk_locked : std_logic;
signal pixel_clk_fb : std_logic;

signal fifty_hz_counter : unsigned(31 downto 0);

signal h_counter : unsigned(9 downto 0);
signal v_counter : unsigned(9 downto 0);

signal x_pos : unsigned(10 downto 0);
signal y_pos : unsigned(10 downto 0);

signal x_inc : signed(1 downto 0);
signal y_inc : signed(1 downto 0);

signal rgb_colour : std_logic_vector(11 downto 0);

begin

------------------------------------------------------------
-- Generate 25 MHz clock for use as pixel clock
------------------------------------------------------------

pixel_clock_gen_inst : PLLE2_BASE
generic map (
    CLKIN1_PERIOD        => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    CLKFBOUT_MULT        => 8,        -- Multiply value for all CLKOUT, (2-64)
    CLKOUT0_DIVIDE       => 32,
    DIVCLK_DIVIDE        => 1        -- Master division value, (1-56)
)
port map (
    -- Clock Input
    CLKIN1   => clk,
    -- Clock Output
    CLKOUT0  => pixel_clk,

   -- Feedback Clock
   CLKFBOUT => pixel_clk_fb,
   CLKFBIN  => pixel_clk_fb,    -- 1-bit input: Feedback clock

   -- Control Ports
   PWRDWN   => '0',
   RST      => '0',

   -- Locked Output
   LOCKED   => pixel_clk_locked
);

-- End of PLLE2_BASE_inst instantiation

reset <= not pixel_clk_locked;

-- Counters for timing H-Sync and V-Sync
h_v_counters_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        h_counter <= h_counter + 1;

        if h_counter = H_LIMIT - 1 then
            h_counter <= (others => '0');
            v_counter <= v_counter + 1;

            if v_counter = V_LIMIT - 1 then
                v_counter <= (others => '0');
            end if;
        end if;

        if reset = '1' then
            h_counter <= (others => '0');
            v_counter <= (others => '0');
        end if;
    end if;
end process;

-- Driving H-Sync and V-Sync based on counters
h_v_sync_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        if h_counter = H_LIMIT - 1 then
            Hsync <= '1';
        end if;
        if h_counter = 95 then
            Hsync <= '0';
        end if;

        if v_counter = V_LIMIT - 1 then
            Vsync <= '1';
        end if;
        if v_counter = 1 then
            Vsync <= '0';
        end if;

        if reset = '1' then
            Hsync <= '0';
            Vsync <= '0';
        end if;
    end if;
end process;

-- Timer for speed of line movement
timer_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        fifty_hz_counter <= fifty_hz_counter + 1;

        if fifty_hz_counter = 500000 then
            fifty_hz_counter <= (others => '0');
        end if;

        if reset = '1' then
            fifty_hz_counter <= (others => '0');
        end if;
    end if;
end process;

-- Generate bouncing x and y positions
xy_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then

        if fifty_hz_counter = 0 then
            x_pos <= unsigned(signed(x_pos) + x_inc);
            y_pos <= unsigned(signed(y_pos) + y_inc);
        end if;

        if (x_pos = 0) or (x_pos = H_RES - 1) then
            x_inc <= -x_inc;
            x_pos <= unsigned(signed(x_pos) + x_inc * 2);
        end if;

        if (y_pos = 0) or (y_pos = V_RES - 1) then
            y_inc <= -y_inc;
            y_pos <= unsigned(signed(y_pos) + y_inc * 2);
        end if;


        if (reset = '1') or (btnC = '1') then
            x_pos <= to_unsigned(H_RES / 2, x_pos'length);
            y_pos <= to_unsigned(V_RES / 2, y_pos'length);
            x_inc <= to_signed(1, x_inc'length);
            y_inc <= to_signed(1, y_inc'length);
        end if;

    end if;
end process;

-- Draw lines at the x and y positions
line_drawing_proc : process(pixel_clk) is
begin
    if rising_edge(pixel_clk) then
        if (h_counter = x_pos + H_L_BORDER) or (v_counter = y_pos + V_T_BORDER) -- Line for pos x & y
        or (h_counter = H_LIMIT - H_R_BORDER - x_pos) or (v_counter = V_LIMIT - V_B_BORDER - y_pos) then -- Line for neg x & y
            rgb_colour <= sw(rgb_colour'range);
        else
            rgb_colour <= (others => '0');
        end if;

        if reset = '1' then
            rgb_colour <= (others => '0');
        end if;
    end if;
end process;

vgaRed   <= rgb_colour(11 downto 8);
vgaGreen <= rgb_colour(7 downto 4);
vgaBlue  <= rgb_colour(3 downto 0);

end rtl;
