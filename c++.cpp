// To Visual Studio compiler

#include "iostream"
#include "windows.h"
#include "math.h"
#include <conio.h>

using namespace std;

int main()
{	
    HANDLE lpt_port = CreateFile("LPT1", GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

    char pressedKey = ' ';

    if (lpt_port != INVALID_HANDLE_VALUE)
    {
        DWORD doubleWordSize;

        cout << "Enter char: " << endl;

        // Until key "esc" is pressed
        while (pressedKey != 0x1b)
        {
            pressedKey = _getch();

            if ((pressedKey == 0) || (pressedKey == 0xe0))
            {
                pressedKey = _getch();
                int functionKey = pressedKey;
                cout << "Pressed the function key: " << functionKey << endl;
            }
            else
            {
                if ((pressedKey >= 0x30 & pressedKey <= 0x39) ||                            // 0123456789
                    (pressedKey >= 0x41 & pressedKey <= 0x5a) ||                            // ABCDEFGHIJKLMNOPQRSTUVWXYZ
                    (pressedKey >= 0x61 & pressedKey <= 0x7a) ||                            // abcdefghijklmnopqrstuvwxyz
                    ((pressedKey >= 0x20 & pressedKey <= 0x22) || (pressedKey == 0x3f)))    // spaces  

                {
                    WriteFile(lpt_port, &pressedKey, 1, &doubleWordSize, NULL);
                    cout << pressedKey;
                }
                else 
                {
                    if (pressedKey == 0x0d)                                                 // enter
                    {                        
                        WriteFile(lpt_port, &pressedKey, 1, &doubleWordSize, NULL);
                        cout << endl;
                    }
                }
            }
        }

        CloseHandle(lpt_port);
    }
    else 
    {
        cout << "Error connecting to the device. Program will be terminated." << endl;
    }

    // Closing
    cout << "Press any key to exit...";

    _getch();	
    return 0;
}