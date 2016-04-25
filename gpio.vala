using GLib;

public const string OUTPUT = "out";
public const string INPUT  = "in";
public const int HIGH = 1;
public const int LOW  = 0;

errordomain InvalidInputError {
	INVALID_GPIO,
	INVALID_DIRECTION
}

void setup(int GPIO, string direction) throws InvalidInputError {
	string pos_ = "sudo echo %i > /sys/class/gpio/export".printf(GPIO);
	Posix.system( pos_ );
	if(direction == OUTPUT || direction == INPUT){
		pos_ = "sudo echo %s > /sys/class/gpio/gpio%i/direction".printf(direction,GPIO);
		Posix.system (pos_);
	}else{
		throw new InvalidInputError.INVALID_DIRECTION ("The expected GPIO direction does not exist");
	}
}

void write (int GPIO, int value) {
	string pos_ = "sudo echo %i > /sys/class/gpio/gpio%i/value".printf(value,GPIO);
	Posix.system(pos_);
}

void close (int GPIO) {
	string pos_ = "sudo echo %i > /sys/class/gpio/unexport".printf(GPIO);
	Posix.system(pos_);
}

int main (){
	setup(11, OUTPUT);
	write(11, HIGH);
	close(11);
	return 0;
}