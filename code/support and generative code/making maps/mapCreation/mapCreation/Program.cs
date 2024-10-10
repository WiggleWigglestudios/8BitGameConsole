using System.Net.NetworkInformation;
using System.Numerics;
using System.IO;
using System.Text;
using System;
using System.Data;
using static System.Runtime.InteropServices.JavaScript.JSType;

string csvName = "map3easierText";

byte[] data = File.ReadAllBytes("C:\\Users\\breck\\Pictures\\6502\\" + csvName+".txt");

string currentStringNumber = "";


List<byte> fileByteData=new List<byte>();
for (int i = 0; i < data.Length; i++) {
    //Console.WriteLine(data[i]);
    if (data[i] < 32 || data[i] == 44)
    {
        if (currentStringNumber.Length > 0)
        {
            fileByteData.Add((byte)int.Parse(currentStringNumber));

            if (fileByteData[fileByteData.Count - 1] == 31) {
                Console.WriteLine("water");
            }

            //   Console.WriteLine(fileByteData[fileByteData.Count-1]);
        }
      //  Console.WriteLine("balls");
        currentStringNumber = "";
    }
    else { 
        currentStringNumber+= (char)data[i];
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

byte[] outputBytes = new byte[mapSizeX * mapSizeY + 2];
outputBytes[0] = (byte)mapSizeX;
outputBytes[1] = (byte)mapSizeY;

//tile number, how many frames of animation
byte[,] specialTiles = {
    { 1,4},
    { 19, 6},
    { 31,8 }

};

List<byte> outputSpecialTilesList = new List<byte>();
outputSpecialTilesList.Add(0);
for (int y = 0; y < mapSizeY; y++)
{
    for (int x = 0; x < mapSizeX; x++)
    {
        outputBytes[x + y * mapSizeX + 2] = fileByteData[fileByteData.Count - (x + y * mapSizeX) - 1];// ();// (byte)( fileByteData[x / 2 + y / 2]*4+ offset[x % 2,y%2]);
        //Console.WriteLine(outputBytes[x * 64 + y]);
        for (int i = 0; i < specialTiles.GetLength(0); i++)
        {
            //if (outputBytes[x + y * mapSizeX + 2] == specialTiles[i,0])
            if (fileByteData[(x + y * mapSizeX)] == specialTiles[i, 0])
            {
                outputSpecialTilesList.Add((byte)i);
                outputSpecialTilesList.Add(specialTiles[i,1]);
                int spotInArray = x + y * mapSizeX + 2;

                outputSpecialTilesList.Add((byte)x);//(byte)((spotInArray >> (8 * 0)) & 0xff));
                outputSpecialTilesList.Add((byte)y);// (byte)((spotInArray >> (8 * 1)) & 0xff));

            }
        }
    }
}


byte[] frameCountOutputBytes =new byte[outputSpecialTilesList.Count-1];

for (int i = 1; i < outputSpecialTilesList.Count; i+=4) {
    frameCountOutputBytes[i - 1] = specialTiles[outputSpecialTilesList[i],0];
}


outputSpecialTilesList[0] =(byte) ((outputSpecialTilesList.Count-1)/4);
File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\making maps\\maps\\" + "map.bin", outputBytes);
File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\making maps\\maps\\" + "mapMovingTiles.bin", outputSpecialTilesList.ToArray());
File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\making maps\\maps\\" + "frameCountBytes.bin", frameCountOutputBytes);
