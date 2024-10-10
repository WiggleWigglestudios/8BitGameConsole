using System.Diagnostics;
using System.IO;
using System;
using System.Collections.Generic;

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");

string filePath = "C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\video\\timing roms\\";
string horizontalRomFileName = "horizontalRom.out";
string verticalRomFileName = "verticalRom.out";

byte[] horizontalRom = new byte[8192];
byte[] verticalRom = new byte[8192];

bool colors = false;
/*rom bits
Horizontal
0 clear
1 vertical clock
2 horizontal timing bit
3 horizontal visible
4
5
6
7 


Vertical
0 clear
1 vertical timing bit
2 vertical visible
3
4
5
6
7 
*/
for (int i = 0; i < 8192; i++) {
    int x = i % 800;
    int y = i % 525;
    //Console.WriteLine(y);
    byte horizontalData = 0;
    byte verticalData = 0;
    //visible
    if (x>2&&x < 640-2)//640
    {
        horizontalData += (byte)Math.Pow(2, 3);

        if (y <= 480&&colors)
        {
            //test colors
            if (((int)x/8) % 2 == 0)
            {
                horizontalData += (byte)Math.Pow(2, 5);
            }
            if (((int)x / 16) % 2 == 0)
            {
                horizontalData += (byte)Math.Pow(2, 6);
            }
            if (((int)x / 32) % 2 == 0)
            {
                horizontalData += (byte)Math.Pow(2, 7);
            }
        }   
    }
    //horizontal sync pulse
    if (!(x>= 656&&x<= 752))
    {
        horizontalData += (byte)Math.Pow(2, 2);
    }
    //horizontal clear signal
    if (x!=799)
    {
        horizontalData += (byte)Math.Pow(2, 0);
    }
    //horizontal x count signal
    if (x < 790)
    {
        horizontalData += (byte)Math.Pow(2, 4);
    }
    //vertical clock signal
    if (x >= 798)
    {
        horizontalData += (byte)Math.Pow(2, 1);
    }



    //vertical visible
    if (y>1&&y < 480-2)//480
    {
        verticalData += (byte)Math.Pow(2, 2);
    }
    //vertical sync pulse
    if (!(y > 490 && y <= 492))
    {
        verticalData += (byte)Math.Pow(2, 1);
    }
    //vertical clear signal
    if (y != 524)
    {
        verticalData += (byte)Math.Pow(2, 0);
    }
    //vertical y count signal
    if (y < 520)
    {
        verticalData += (byte)Math.Pow(2, 3);
    }



    horizontalRom[i] = horizontalData;
    verticalRom[i] = verticalData;

}


System.IO.File.WriteAllBytes(filePath + horizontalRomFileName, horizontalRom);
System.IO.File.WriteAllBytes(filePath + verticalRomFileName, verticalRom);