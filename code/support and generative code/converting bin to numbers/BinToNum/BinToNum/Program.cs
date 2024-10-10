// See https://aka.ms/new-console-template for more information
using System.Diagnostics;

Console.WriteLine("Hello, World!");

byte[] bytesToConver = File.ReadAllBytes("C:\\Users\\breck\\Pictures\\6502\\tileSetWithDad.bin");
List<char> outputChars= new List<char>();
String outputString = "";
for (int i = 0; i < bytesToConver.Length; i++) {
    Debug.WriteLine(bytesToConver[i]);
    outputChars.Add((char)(("" + bytesToConver[i])[0]));
    outputString += (int)bytesToConver[i] + ",";
}
byte[] outputBytes=new byte[outputChars.Count*2];

for (int i = 0; i < outputChars.Count; i+=2)
{
    outputBytes[i] = (byte)(outputChars[i]);
    outputBytes[i+1] = (byte)(',');
}

//File.WriteAllBytes("C:\\Users\\breck\\Pictures\\6502\\tileSet1Text.txt", outputBytes);
File.WriteAllText("C:\\Users\\breck\\Pictures\\6502\\tileSetWithDad.txt", outputString);