extern "C" void  Printf(const char*, ...);

const char* pol = "This is cool!!!!";

int main()
{
       Printf("I love %x na %b%%%c \nI %s %x %d%%%c%b\n", 3802, 8, '!', "love", 3802, 100, 33, 255);
    // Printf("Poltorashka");
    // Printf("POLTORASHKA %z %b %d %o %c %x RULEZ \n", 120, 120, 120, 120);
    return 0;

}