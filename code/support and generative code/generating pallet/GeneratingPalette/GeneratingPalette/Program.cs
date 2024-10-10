using System.Net.NetworkInformation;
using System.Numerics;
using System.IO;
using System.Text;

//grayscale
byte[] samplePalette =
{
    0,
    82,
    164,
    246
};

samplePalette =new byte[]{
   // 0,
    //9,
    18,
    27,
    36,
    45,
    54,
    63
};

int paletteSize = 256;

byte[] outputPalette= new byte[paletteSize];

for(int i = 0; i < paletteSize; i++)
{
    outputPalette[i]= samplePalette[(int)(i/ ((float)(paletteSize)/(float)(samplePalette.Length)))];
    //Console.WriteLine(outputPalette[i]);
}
File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\testPalette.bin", outputPalette);