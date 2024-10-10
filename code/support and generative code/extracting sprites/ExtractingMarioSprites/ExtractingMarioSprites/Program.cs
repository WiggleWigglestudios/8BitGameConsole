using System.Net.NetworkInformation;
using System.Drawing;
using System.Numerics;
using System.IO;
using System.Text;
using System;

Color[] pallet1 = {
     Color.FromArgb(255,0, 0,0),
     Color.FromArgb(255,255, 0,0),
     Color.FromArgb(255,0, 255,0),
     Color.FromArgb(255,255, 255,0),
     Color.FromArgb(255,0, 0,255),
     Color.FromArgb(255,255, 0,255),
     Color.FromArgb(255,0, 255,255),
     Color.FromArgb(255,255, 255,255),
};
Color[] pallet2 = new Color[(int)Math.Pow(2, 3 + 3 + 2)];

for (int i = 0; i < pallet2.Length; i++)
{

    var r = ((i >> 2) & 1) * 255 / 2 + ((i >> 1) & 1) * 255 / 4 + ((i >> 0) & 1) * 255 / 8;
    var g = ((i >> 5) & 1) * 255 / 2 + ((i >> 4) & 1) * 255 / 4 + ((i >> 3) & 1) * 255 / 8;
    var b = ((i >> 7) & 1) * 125 + ((i >> 6) & 1) * 125;
    pallet2[i] = Color.FromArgb(255, r, g, b);

}



Color[] pallet = pallet2;

Console.WriteLine("Starting");
string imageName = "map3EasierTileSet"; //"playerSpriteSheetFacingLeftAndRight";//"nesTileSet"; //"c64_Font";//
string imageFileFormat = "png";



Bitmap bitmapNormal = new Bitmap("C:\\Users\\breck\\Pictures\\6502\\" + imageName + "." + imageFileFormat);
Color clr;
string outputPath = "C:\\Users\\breck\\Pictures\\6502\\tileSet.bin";

//mario spots
int[,] positionsOfCharacters = {
    {0,0},
    {1,0},
    {0,1},
    {1,1},
    {2,0},
    {3,0},
    {2,1},
    {3,1},
    {4,0},
    {5,0},
    {4,1},
    {5,1},
    {6,0},
    {7,0},
    {6,1},
    {7,1},
    {8,0},
    {9,0},
    {8,1},
    {9,1},
    {10,0},
    {11,0},
    {10,1},
    {11,1},
    {12,0},
    {13,0},
    {12,1},
    {13,1},
    {14,0},
    {15,0},
    {14,1},
    {15,1},
    {16,0},
    {17,0},
    {16,1},
    {17,1},
    {18,0},
    {19,0},
    {18,1},
    {19,1},
    {20,0},
    {21,0},
    {20,1},
    {21,1},
    {22,0},
    {23,0},
    {22,1},
    {23,1},
    {24,0},
    {25,0},
    {24,1},
    {25,1},
    {26,0},
    {27,0},
    {26,1},
    {27,1},
    {28,0},
    {29,0},
    {28,1},
    {29,1},
    {30,0},
    {31,0},
    {30,1},
    {31,1},
    {0,2},
    {1,2},
    {0,3},
    {1,3},
    {2,2},
    {3,2},
    {2,3},
    {3,3},
    {4,2},
    {5,2},
    {4,3},
    {5,3},
    {6,2},
    {7,2},
    {6,3},
    {7,3},
    {8,2},
    {9,2},
    {8,3},
    {9,3},
    {10,2},
    {11,2},
    {10,3},
    {11,3},
    {12,2},
    {13,2},
    {12,3},
    {13,3},
    {14,2},
    {15,2},
    {14,3},
    {15,3},
    {16,2},
    {17,2},
    {16,3},
    {17,3},
    {18,2},
    {19,2},
    {18,3},
    {19,3},
    {20,2},
    {21,2},
    {20,3},
    {21,3},
    {22,2},
    {23,2},
    {22,3},
    {23,3},
    {24,2},
    {25,2},
    {24,3},
    {25,3},
    {26,2},
    {27,2},
    {26,3},
    {27,3},
    {28,2},
    {29,2},
    {28,3},
    {29,3},
    {30,2},
    {31,2},
    {30,3},
    {31,3},
};

//for normal map
if (true)
{
    positionsOfCharacters = new int[128, 2];
    for (int i = 0; i < 121; i++) {
        positionsOfCharacters[i, 0] = i % 11;
        positionsOfCharacters[i, 1] = i / 11;
    }
    for (int i = 121; i < 128; i++)
    {
        positionsOfCharacters[i, 0] = -1;
        positionsOfCharacters[i, 1] = -1;
    }

}

//for my game
if (true)
{
    int tiles = 70;
    int width = 70;
    int height = 70;
    positionsOfCharacters = new int[tiles, 2];
    for (int i = 0; i < tiles; i++)
    {
        positionsOfCharacters[i, 0] = i%width;
        positionsOfCharacters[i, 1] = i/height;
    }
}
byte backgroundColor = 0b01001001;//0b10010000

byte[] outputBytes = new byte[positionsOfCharacters.GetLength(0) * 8 * 8];
for (int i = 0; i < outputBytes.Length; i++)
{
    
        int x = positionsOfCharacters[i / 64, 0] * 8;
        int y = positionsOfCharacters[i / 64, 1] * 8;
    if (!(x < 0 || y < 0))
    {

        x += i % 8;
        y += (i % 64) / 8;

        clr = bitmapNormal.GetPixel(x, y);
        int closest = 0;
        int dist = 1000000;
        for (int p = 0; p < pallet.Length; p++)
        {
            int d = (int)Math.Sqrt(Math.Pow(pallet[p].R - clr.R, 2) + Math.Pow(pallet[p].G - clr.G, 2) + Math.Pow(pallet[p].B - clr.B, 2));
            if (d < dist)
            {
                dist = d;
                closest = p;
            }
        }
        outputBytes[i] = (byte)closest;
        if(clr.A == 0)
        {
            outputBytes[i] = backgroundColor;
        }
    }
    else {

        outputBytes[i] = backgroundColor;
    }
    //Console.WriteLine(x + " " + y+" " + outputBytes[i]);
}
File.WriteAllBytes(outputPath, outputBytes);



/*
byte[] outputBin = new byte[128*8*8];
int byteOn = 0;
for (int x = 0; x < 16; x++)
{


    for (int y = 0; y < 2; y++)
    {

        for (int b = 0; b < 4; b++)
        {
            for (int i = 0; i < 64; i++)
            {
                int px = x*16+b%2*8+i%8;
                int py = y*16+b/2*8+i/8;
               //Console.WriteLine(px + "," + py);
                clr = bitmapNormal.GetPixel(px, py);
                int closest = 0;
                int dist = 1000000;
                for (int p = 0; p < pallet.Length; p++)
                {
                    int d = (int)Math.Sqrt(Math.Pow(pallet[p].R - clr.R, 2) + Math.Pow(pallet[p].G - clr.G, 2) + Math.Pow(pallet[p].B - clr.B, 2));
                    if (d < dist)
                    {
                        dist = d;
                        closest = p;
                    }
                }
                outputBin[byteOn] = (byte)closest;
                byteOn++;
            }
        }
    }
}






File.WriteAllBytes(imageOutputBinFilePath, outputBin);



*/
