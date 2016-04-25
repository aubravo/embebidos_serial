public static int main (string[] args) {
	FileStream stream = FileStream.open ("/sys/class/gpio/export", "r");		
	assert ( stream != null );
	
	stream.puts("11");	
	

	return 0;
}