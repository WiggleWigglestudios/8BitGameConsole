using System.Drawing;
using System.IO;
using System.Text;

string ComFontPath = "C:\\Users\\breck\\Pictures\\6502\\c64_Font.png";
string outputPath = "C:\\Users\\breck\\Pictures\\6502\\font.bin";
Bitmap img = new Bitmap(ComFontPath);

int[,] positionsOfCharacters = {
    {-1,-1},//null
    {-1,-1},//start of heading
    {-1,-1},//start of text
    {-1,-1},//end of text
    {-1,-1},//end of transmission
    {-1,-1},//enquiry
    {-1,-1},//acknowledge
    {-1,-1},//bell
    {-1,-1},//backspace
    {-1,-1},//horizontal tab
    {-1,-1},//new line
    {-1,-1},//vertical tab
    {-1,-1},//new page
    {-1,-1},//carriage return
    {-1,-1},//shift out
    {-1,-1},//shift in
    {-1,-1},//data link escape
    {-1,-1},//device control 1
    {-1,-1},//device control 2
    {-1,-1},//device control 3
    {-1,-1},//device control 4
    {-1,-1},//negative acknowledge
    {-1,-1},//synchronous idle
    {-1,-1},//end of transmition
    {-1,-1},//cancle
    {-1,-1},//end of medium
    {-1,-1},//substitue
    {-1,-1},//escape
    {-1,-1},//file separator
    {-1,-1},//group separator
    {-1,-1},//record separator
    {-1,-1},//unit separator

    {0,5},//space
    {1,5},//!
    {2,5},//"
    {3,5},//#
    {4,5},//$
    {5,5},//%
    {6,5},//&
    {7,5},//'
    {8,5},//(
    {9,5},//)
    {10,5},//*
    {11,5},//+
    {12,5},//,
    {13,5},//-
    {14,5},//.
    {15,5},// /
    {16,5},//0
    {17,5},//1
    {18,5},//2
    {19,5},//3
    {20,5},//4
    {21,5},//5
    {22,5},//6
    {23,5},//7
    {24,5},//8
    {25,5},//9
    {26,5},//:
    {27,5},//;
    {28,5},//<
    {25,5},//=
    {26,5},//>
    {27,5},//?
    
    {0,4},//@
    {1,4},//A
    {2,4},//B
    {3,4},//C
    {4,4},//D
    {5,4},//E
    {6,4},//F
    {7,4},//G
    {8,4},//H
    {9,4},//I
    {10,4},//J
    {11,4},//K
    {12,4},//L
    {13,4},//M
    {14,4},//N
    {15,4},//O
    {16,4},//P
    {17,4},//Q
    {18,4},//R
    {19,4},//S
    {20,4},//T
    {21,4},//U
    {22,4},//V
    {23,4},//W
    {24,4},//X
    {25,4},//Y
    {26,4},//Z
    {27,4},//[
    {13,6},//\
    {25,4},//]
    {26,4},//^
    {18,6},//_
        
    {7,5},//`
    {1,4},//a
    {2,4},//b
    {3,4},//c
    {4,4},//d
    {5,4},//e
    {6,4},//f
    {7,4},//g
    {8,4},//h
    {9,4},//i
    {10,4},//j
    {11,4},//k
    {12,4},//l
    {13,4},//m
    {14,4},//n
    {15,4},//o
    {16,4},//p
    {17,4},//q
    {18,4},//r
    {19,4},//s
    {20,4},//t
    {21,4},//u
    {22,4},//v
    {23,4},//w
    {24,4},//x
    {25,4},//y
    {26,4},//z
    {27,4},//{
    {25,6},//|
    {25,4},//}
    {26,4},//~
    {18,6},//Del



};

byte[] uni = Encoding.Unicode.GetBytes("Whatever unicode string you have");
string Ascii = Encoding.ASCII.GetString(uni);
Console.WriteLine(Ascii.Length);
for (int i = 0; i < Ascii.Length; i+=2)
{
    Console.WriteLine(Ascii[i]);
}
byte[] outputBytes = new byte[positionsOfCharacters.GetLength(0)*8*8];
for (int i = 0; i < outputBytes.Length; i++) {
    int x = positionsOfCharacters[i / 64, 0]*8;
    int y = positionsOfCharacters[i / 64, 1]*8;

    if (x >= 0 && y >= 0)
    {
        x += i % 8;
        y += (i % 64) / 8;

        if (img.GetPixel(x, y).R > 128)
        {

            outputBytes[i] = 255;
        }
        else
        {

            outputBytes[i] = 0;
        }

        if (i < 32*64) {
            outputBytes[i] = 255;//(byte) (x+i/64*8);
        }

    }
    else
    {
        x += i % 8;
        outputBytes[i] = 0;
        outputBytes[i] = (byte) (x+i/64*8);
    }
      //Console.WriteLine(x + " " + y+" " + outputBytes[i]);
}
File.WriteAllBytes(outputPath, outputBytes);