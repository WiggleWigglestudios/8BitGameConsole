using System.Drawing;
using System.IO;


string ComFontPath = "C:\\Users\\breck\\Pictures\\6502\\c64_Font.png";
string outputPath = "C:\\Users\\breck\\Pictures\\6502\\font.bin";
Bitmap img = new Bitmap(ComFontPath);

byte[] outputBytes = new byte[26*8*8 + 10*8*8 + 16*8*8];

for (int x = 8; x < 216; x++) 
{ 
    for(int y = 0; y < 8; y++) 
    {
        if (img.GetPixel(x, y).R > 128)
        {

            outputBytes[(x - 8) * 8 + y] = 0b00000111;
        }
        else {

            outputBytes[(x - 8) * 8 + y] = 0b00111000;
        }

    }
}

for (int i = 0; i < (26 * 8 * 8); i++) {
    int x = 8+i%8+(int)(i/64)*8;
    int y = (i%64)/8;
    //Console.WriteLine(x + " " + y);
    if (img.GetPixel(x, y).R < 128)
    {

        outputBytes[i] = 255; //0b00000111;
    }
    else
    {

        outputBytes[i] = 0;//0b00111000;
    }
   

}

for (int i = 0; i < (10 * 8 * 8); i++)
{
    int x = 8*16 + i % 8 + (int)(i / 64) * 8;
    int y = 8+(i % 64) / 8;
    //Console.WriteLine(x + " " + y);
    if (img.GetPixel(x, y).R < 128)
    {

        outputBytes[i+ (26 * 8 * 8)] = 255; //0b00000111;
    }
    else
    {

        outputBytes[i+(26 * 8 * 8)] = 0;//0b00111000;
    }


}

for (int i = 0; i < (16 * 8 * 8); i++)
{

        outputBytes[i + (26 * 8 * 8)+ (10 * 8 * 8)] = (byte)(i/4); //0b00000111;
   

}


File.WriteAllBytes(outputPath, outputBytes);