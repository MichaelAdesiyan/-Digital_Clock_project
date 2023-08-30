library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--111 rst,110 stopwatch,101 set,100 timer,001 alarm,others clockmode
entity digital_clock is
port( clk,sw0,sw1,sw2,btn1,btn2			: in std_logic;
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0);
		LEDR: out std_logic_vector(9 downto 0):="0000000000";
		sec_blink,rst_LED,timer_LED,alarm_LED,stopwatch_LED,set_LED: out std_logic
		);
		

end entity digital_clock;

architecture clock of digital_clock is
	constant clk_freq : integer := 50e6; -- The clock frequency of the DE10-Lite is 50 MHz.
	
	component functs_select_mux is
		port( sel:in std_logic_vector(2 downto 0);
		a,b,c,d,e,f:in integer:=0;
		output:out integer
		);
	end component;
	
	component functs_switch is
		port( sw:in std_logic_vector(2 downto 0);
		output:out integer
		);
	end component;
	
	component clock_sum is
		port( inputa,inputb,inputc,inputd,inpute,inputf,inputg:in integer:=0;
		outputmin1,outputmin2,outputhour1,outputhour2:out integer
		);
	end component;
	-- constants to display appropriate digits on the 7-segment displays
	signal zero	: std_logic_vector(6 downto 0) := "1000000";
	signal one	: std_logic_vector(6 downto 0) := "1111001";
	signal two	: std_logic_vector(6 downto 0) := "0100100";
	signal three	: std_logic_vector(6 downto 0) := "0110000";
	signal four	: std_logic_vector(6 downto 0) := "0011001";
	signal five	: std_logic_vector(6 downto 0) := "0010010";
	signal six	: std_logic_vector(6 downto 0) := "0000010";
	signal seven	: std_logic_vector(6 downto 0) := "1111000";
	signal eight	: std_logic_vector(6 downto 0) := "0000000";
	signal nine	: std_logic_vector(6 downto 0) := "0010000";
	
	signal rst,timer,alarm,stopwatch,set:std_logic;
	-- array that will contain the above 10 constants in an array
	type digitsArray is array(0 to 9) of std_logic_vector(6 downto 0);
	signal digits: digitsArray;
	
	--variables used for the array indexing in order to display appropriate digit
	--they have to be defined as shared variable because they are outside process
	--and process will alter their values
	signal sec_read1,sec_read2,min_read1,min_read2,hour_read1,hour_read2 : natural range 0 to 9;
	
	signal sec1_read1,sec1_read2,min1_read1,min1_read2,hour1_read1,hour1_read2 : natural range 0 to 9:=0;--clockmode
	signal sec2_read1,sec2_read2,min2_read1,min2_read2,hour2_read1,hour2_read2 : natural range 0 to 9:=0;--setmode
	signal cmin1,cmin2,chour1,chour2,setmin,sethour: integer:=0;
	
	signal function_switch: integer:=0;--0 clockmode,10 resetmode,20 
	--the signal that give 1Hz clock which will be updated by the create_1Hz_clk process below
	signal sec_signal:std_logic:='0';
	signal min_signal,hour_signal: std_logic:='1';
	
	procedure compute_seconds(signal sec1: inout integer;signal sec2:inout integer) is
	begin
		if sec1>=9 then
			sec2<=sec2+1;
			if sec2>=5 then
				sec2<=0;
			end if;
			sec1<=0;
			
		end if;
	end procedure;
	
	procedure compute_minutes(signal min1: inout integer;signal min2:inout integer) is
	begin
		if (min1>=9) then
			min1<=0;
			min2<=min2+1;
			if(min2>=5) then
				min2<=0;
			end if;
		end if;
	end procedure;
	
	procedure compute_hours(signal hour1: inout integer;signal hour2:inout integer) is
	begin
		hour1<=hour1+1;
		if hour2=1 and hour1>=9 then
			hour2<=hour2+1;
			hour1<=0;
		elsif hour2=2 and hour1>=3 then
			hour2<=0;
			hour1<=0;
		end if;
	end procedure;

begin
	hexdisp1:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>sec1_read1,output=>sec_read1);
	hexdisp2:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>sec1_read2,output=>sec_read2);
	hexdisp3:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>cmin1,output=>min_read1);
	hexdisp4:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>cmin2,output=>min_read2);
	hexdisp5:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>chour1,output=>hour_read1);
	hexdisp6:functs_select_mux port map(sel(0)=>sw0,sel(1)=>sw1,sel(2)=>sw2,f=>chour2,output=>hour_read2);
	
	
	functions_switch: functs_switch port map(sw(0)=>sw0,sw(1)=>sw1,sw(2)=>sw2,output=>function_switch);
	
	sum_min1:clock_sum port map(inputa=>setmin,inputb=>min1_read1,inputc=>sethour,inputd=>hour1_read1,
	inpute=>min1_read2,inputf=>hour1_read2,inputg=>function_switch,
	outputmin1=>cmin1,outputmin2=>cmin2,outputhour1=>chour1,outputhour2=>chour2);
	
	--this is where the constants are layed on the above defined array
	digits<=(zero,one,two,three,four,five,six,seven,eight,nine);
	
	--this process generate 1Hz signal
	create_1Hz_clk: process(clk,function_switch)
	variable cnt : integer range 0 to clk_freq := 0;
	begin
		if function_switch=10 then
			cnt:=0;sec_signal<='0';
		elsif rising_edge(clk) then
			if cnt >= clk_freq/2 then
				sec_signal <= not sec_signal;
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	
	
	sec_count: process(sec_signal,function_switch)
		variable cnt: integer range 0 to 60:=0;
	begin
		if function_switch=10 then
				cnt:=0;sec1_read1<=0;sec1_read2<=0;min_signal<='1';
		elsif function_switch=30 then
			
		elsif rising_edge(sec_signal) then
			sec1_read1<=sec1_read1+1;
			cnt:=cnt+1;
			
			if cnt=30 then
				min_signal<=not min_signal;
				cnt:=0;
			end if;
			compute_seconds(sec1_read1,sec1_read2);
		end if;
		-- seconds reading part ends
		
	end process;
	
	min_count: process(min_signal,function_switch,btn1)
		variable cnt: integer range 0 to 60:=0;
		variable setmincnt: integer:=0;
	begin
		
		if function_switch=10 then
			cnt:=0;min1_read1<=0;min1_read2<=0;hour_signal<='1';
		elsif function_switch=30 then
			if btn1='1' then
				
				setmincnt:=setmincnt+1;
				setmin<=setmincnt;
				if setmincnt>10 then
					setmincnt:=0;
				end if;
			end if;
		elsif rising_edge(min_signal) then
			setmincnt:=0;
			setmin<=0;
			min1_read1<=min1_read1+1;
			cnt:=cnt+1;
			if cnt=30 then
				hour_signal<=not hour_signal;
				cnt:=0;
			end if;
			compute_minutes(min1_read1,min1_read2);
			
		end if;
	end process;
	
	hour_count: process(hour_signal,function_switch,btn2)
		variable sethourcnt: integer:=0;
	begin
		if function_switch=10 then
			hour1_read1<=0;hour1_read2<=0;
		elsif function_switch=30 then
			
		elsif rising_edge(hour_signal) then
			sethourcnt:=0;
			sethour<=0;
			compute_hours(hour1_read1,hour1_read2);
		end if;
	end process;
	
	
	indicators:process(function_switch)
	begin
		rst<='0';timer<='0';alarm<='0';stopwatch<='0';set<='0';
		if function_switch=10 then
			rst<='1';timer<='0';alarm<='0';stopwatch<='0';set<='0';
		elsif function_switch=20 then
			stopwatch<='1';rst<='0';timer<='0';alarm<='0';set<='0';
		elsif function_switch=30 then
			set<='1';rst<='0';timer<='0';alarm<='0';stopwatch<='0';
		elsif function_switch=40 then
			timer<='1';rst<='0';alarm<='0';stopwatch<='0';set<='0';
		elsif function_switch=50 then
			alarm<='1';rst<='0';timer<='0';stopwatch<='0';set<='0';
		end if;
	end process;
	
	HEX5<=digits(hour_read2); HEX4<=digits(hour_read1); 
	
	HEX3<=digits(min_read2); HEX2<=digits(min_read1);
	
	HEX1<=digits(sec_read2); HEX0<=digits(sec_read1);
	
	rst_LED<=rst;
	
	sec_blink<=sec_signal;timer_LED<=timer;alarm_LED<=alarm;stopwatch_LED<=stopwatch;set_LED<=set;
	
	
end architecture clock;