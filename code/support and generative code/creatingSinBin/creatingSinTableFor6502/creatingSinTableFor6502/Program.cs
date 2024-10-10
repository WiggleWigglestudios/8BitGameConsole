using System.IO;


string sinFileLow = "C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\sinTableLow.bin";
string sinFileHigh = "C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\sinTableHigh.bin";
byte[] sinBytesLow = new byte[256];
byte[] sinBytesHigh = new byte[256];


for (int i = 0; i < sinBytesLow.Length; i++) {
    double sinValue= Math.Sin(((double)(i) / (double)(sinBytesLow.Length)) * 2 * Math.PI);
    double originalValue = sinValue;
    int topBit = (int)sinValue;
    int sign = Math.Sign(sinValue);
    sinValue -= topBit;
    topBit *= sign;
    //sinValue *= 100;
  //  sinValue /= 100;
    sinValue *= 256;
    sinValue=Math.Floor(Math.Abs(sinValue));

    byte topByte = (byte)topBit;
    byte lowByte = (byte)sinValue;


  //  Console.WriteLine(sinValue + "\t \t" + topBit + " " + topByte + " " + lowByte);
    if (sign == -1)
    {
        topByte = (byte)((int)topByte ^ 255);
        lowByte = (byte)((int)lowByte ^ 255);

        lowByte++;
        if(lowByte == 0)
        {
            topByte++;
        }
    }
    double recalculatedValue = (double)(127&(int)topByte)+(double)lowByte/256-(double)(128 & (int)topByte);
    Console.WriteLine(originalValue+" "+recalculatedValue);
    sinBytesLow[i] = lowByte;
    sinBytesHigh[i] = topByte;
}

Console.WriteLine("high Bytes:");

for (int i = 0; i < sinBytesHigh.Length; i++)
{

    Console.WriteLine("\t.byte "+(int)sinBytesHigh[i]);
}

Console.WriteLine("low Bytes:");
for (int i = 0; i < sinBytesLow.Length; i++)
{

    Console.WriteLine("\t.byte " + (int)sinBytesLow[i]);
}

File.WriteAllBytes(sinFileLow, sinBytesLow);
File.WriteAllBytes(sinFileHigh, sinBytesHigh);