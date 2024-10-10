using System.Net.NetworkInformation;
using System.Numerics;
using System.IO;
using System.Text;
using System;
using System.Data;
using static System.Runtime.InteropServices.JavaScript.JSType;

string csvName = "map3easierText";

byte[] data = File.ReadAllBytes("C:\\Users\\breck\\Pictures\\6502\\" + csvName + ".txt");

string currentStringNumber = "";


List<byte> fileByteData = new List<byte>();
for (int i = 0; i < data.Length; i++)
{
    //Console.WriteLine(data[i]);
    if (data[i] < 32 || data[i] == 44)
    {
        if (currentStringNumber.Length > 0)
        {
            //Console.Write(currentStringNumber+" ");
            fileByteData.Add((byte)int.Parse(currentStringNumber));

            if (fileByteData[fileByteData.Count - 1] == 31)
            {
                //Console.WriteLine("water");
            }

            //   Console.WriteLine(fileByteData[fileByteData.Count-1]);
        }
        //  Console.WriteLine("balls");
        currentStringNumber = "";
    }
    else
    {
        currentStringNumber += (char)data[i];
    }

}

byte[,] offset = {
   {0,0},
   {1,0},
   {0,1},
   {1,1},

};

int mapSizeX = 40;
int mapSizeY = 30;

byte[] outputBytes = new byte[64 * 32 ];
outputBytes[0] = (byte)mapSizeX;
outputBytes[1] = (byte)mapSizeY;

//tile number, how many frames of animation
byte[,] specialTiles = {
    { 1,4},
    { 19, 6},
    { 31,8 }

};

int[] transparentBlocks ={0, 19, 20, 21, 22, 23, 24, 29, 30, 39, 41, 42, 43, 44, 31, 32, 33, 34, 35, 36, 37, 38, 45, 28, 25,47,49,50,65};
int[] waterBlocks = {31,32,33,34,35,36,37,38,45 };
int[] spikeBlocks = { 25, 28 };
int[] checkPointBlocks = {29,30};

string outputMap = "";
List<byte> outputSpecialTilesList = new List<byte>();
outputSpecialTilesList.Add(0);
for (int y = 0; y < 32; y++)
{
    for (int x = 0; x < 64; x++)
    {
        if (x < mapSizeX && y < mapSizeY)
        {
            outputBytes[x + y * 64] = 0;
            bool transparent = false;
            int tileData = fileByteData[(x + y * mapSizeX)];

            for (int i = 0; i < transparentBlocks.Length; i++) {
                if (tileData == transparentBlocks[i]) {
                    transparent = true;
                }
            }

            if (!transparent)
            {
                outputBytes[x + y * 64] += 1;// fileByteData[fileByteData.Count - (x + y * mapSizeX) - 1];
            }

            bool water = false;

            for (int i = 0; i < waterBlocks.Length; i++)
            {
                if (tileData == waterBlocks[i])
                {
                    water = true;
                }
            }

            if (water)
            {
                outputBytes[x + y * 64] += 2;// fileByteData[fileByteData.Count - (x + y * mapSizeX) - 1];
            }

            bool spike = false;

            for (int i = 0; i < spikeBlocks.Length; i++)
            {
                if (tileData == spikeBlocks[i])
                {
                    spike = true;
                }
            }

            if (spike)
            {
                outputBytes[x + y * 64] += 4;// fileByteData[fileByteData.Count - (x + y * mapSizeX) - 1];
            }

            bool checkPoint = false;

            for (int i = 0; i < checkPointBlocks.Length; i++)
            {
                if (tileData == checkPointBlocks[i])
                {
                    checkPoint = true;
                }
            }

            if (checkPoint)
            {
                outputBytes[x + y * 64] += 8;// fileByteData[fileByteData.Count - (x + y * mapSizeX) - 1];
            }

            //outputMap +="("+(transparent?0:1) + ",";
        }
        else {
            outputBytes[x + y * 64] = 0;

            //outputMap += (-1) + " ";
        }

        outputMap += outputBytes[x + y * 64];// +") ";
    }
    outputMap += "\n";
}


byte[] frameCountOutputBytes = new byte[outputSpecialTilesList.Count - 1];

for (int i = 1; i < outputSpecialTilesList.Count; i += 4)
{
    frameCountOutputBytes[i - 1] = specialTiles[outputSpecialTilesList[i], 0];
}


outputSpecialTilesList[0] = (byte)((outputSpecialTilesList.Count - 1) / 4);
File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\making maps\\maps\\" + "collision.bin", outputBytes);
File.WriteAllText("C:\\Users\\breck\\Pictures\\6502\\testCollisionMap.txt", outputMap);