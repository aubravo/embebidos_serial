namespace Raspberry {
	public errordomain InvalidInputError {
		INVALID_GPIO,
		INVALID_DIRECTION
	}

	public const string _export = "/sys/class/gpio/export";
	public const string _uexport = "/sys/class/gpio/unexport";
	public const string OUTPUT = "out";
	public const string INPUT  = "in";
	public const int HIGH = 1;
	public const int LOW  = 0;

	public void wait_s (int seconds){
		Posix.usleep(seconds*1000000);
	}

	public void wait_ms (int mseconds){
		Posix.usleep(mseconds*1000);
	}

	public void wait_us (int useconds){
		Posix.usleep(useconds);
	}

	public class GPIOPort : Object {
		
		private int _gpioPort;	
	
		public GPIOPort (int _gpioPort){
			if ( _gpioPort > 0 || _gpioPort < 28 ){
				this._gpioPort = _gpioPort;
				FileStream _stream = FileStream.open(_export,"w");
				assert (_stream != null);
				_stream.puts (this._gpioPort.to_string());
			}else { throw new InvalidInputError.INVALID_GPIO ("The provided GPIO port does not exist"); }
		}
		
		public void setup(string direction) throws InvalidInputError {
			bool succ = false;
			for ( int i = 0 ; i <= 10 && succ == true ; i++ ){
				try{
					if(direction == OUTPUT || direction == INPUT){
						string dir_ = "/sys/class/gpio/gpio%i/direction".printf(this._gpioPort);
						FileStream _stream = FileStream.open (dir_ ,"w");
						assert (_stream != null);
						_stream.puts (direction);
						succ = true;
					}else{throw new InvalidInputError.INVALID_DIRECTION ("The provided GPIO direction does not exist");}
				}catch{stdout.printf("cannot setup GPIO, will attempt to connect again");}
			}
		}
		
		public void write (int value) {
			string dir_ = "/sys/class/gpio/gpio%i/value".printf(this._gpioPort);
			FileStream _stream = FileStream.open (dir_ ,"w");
			assert (_stream != null);
			_stream.puts (value.to_string());
		}
		
		public int read (){
			string dir_ = "/sys/class/gpio/gpio%i/value".printf(this._gpioPort);
			FileStream _stream = FileStream.open (dir_ ,"r");
			assert (_stream != null);
			int c = _stream.getc () - 48;
			return c;
		}

		public void close () {
			FileStream _stream = FileStream.open(_uexport,"w");
			assert (_stream != null);
			_stream.puts (this._gpioPort.to_string());
		}
		
	}

	public class Serial : Object {
		public string port { get; set; default = "/dev/ttyAMA0";}
		
		
		
		
		
	}
}

int main(){ 
	int fd = Posix.open ("/dev/ttyS0", Posix.O_RDWR | Posix.O_NOCTTY );
	
	if (fd < 0) stdout.printf ("Unable to open Port");
	else stdout.printf ("Connected");

	Posix.termios newtio;
	
	Posix.tcgetattr(fd, out newtio);
	
	Posix.cfsetospeed(ref newtio, Posix.B9600);
	Posix.cfsetispeed(ref newtio, Posix.B9600);

	Posix.tcsetattr (fd, Posix.TCSANOW, newtio);
	newtio.c_cflag = (newtio.c_cflag & ~Posix.CSIZE) | Posix.CS8;
	
	newtio.c_cflag |= Posix.CLOCAL | Posix.CREAD;

	newtio.c_cflag &= ~(Posix.PARENB | Posix.PARODD);
        newtio.c_cflag |= (Posix.PARENB | Posix.PARODD);

	newtio.c_cflag |= Posix.CSTOPB;

	newtio.c_iflag = Posix.IGNBRK;
	
	newtio.c_iflag &= ~(Posix.IXON | Posix.IXOFF | Posix.IXANY);

	newtio.c_lflag = 0;
        newtio.c_oflag = 0;
        newtio.c_cc[Posix.VTIME]=1;
        newtio.c_cc[Posix.VMIN]=1;
        newtio.c_lflag &= ~(Posix.ECHONL|Posix.NOFLSH);

	Posix.tcsetattr(fd, Posix.TCSANOW, newtio);
	
	while (true) {
		uchar[] m_buf=new uchar[128];
		int bytesleidos=(int)Posix.read(fd,m_buf,128);

		string datosleidos;

		if(bytesleidos<0)
			{
				return -1;
			}
			uchar[] sized_buf = new uchar[bytesleidos];
			for(int x=0;x<bytesleidos;x++)
			{
				sized_buf[x]=m_buf[x];
			}
			
			StringBuilder builder = new StringBuilder();
			for(int ctr=0; ctr<bytesleidos;ctr++)
			{
				if(sized_buf[ctr]!='\0')
					builder.append_c((char)sized_buf[ctr]);
				else
					break;
			}
			
			datosleidos=builder.str;

			stdout.printf(datosleidos);
	}

	return 0;
}

