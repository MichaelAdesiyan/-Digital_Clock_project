library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity functs_switch is
port( sw:in std_logic_vector(2 downto 0);
		output:out integer
		);
		

end entity functs_switch;

architecture clock of functs_switch is
	
begin
	process(sw(2),sw(1),sw(0))
	begin
		if sw="111" then
			output<=10;
		elsif sw="110" then
			output<=20;
		elsif sw="101" then
			output<=30;
		elsif sw="100" then
			output<=40;
		elsif sw="001" then
			output<=50;
		else
			output<=0;
		end if;
	end process;
	
end architecture clock;