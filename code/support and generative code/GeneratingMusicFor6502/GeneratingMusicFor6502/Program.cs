using MathNet.Numerics.IntegralTransforms; //for fft


string outputPath = "C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\testMusic1.bin";

float[] frequencies =new float[256];

for (int i = 1; i < frequencies.Length; i++) {
    frequencies[i] = 1000000 / (16 * i);
   // Console.WriteLine(frequencies[i]);
}

Dictionary<string,float> notesDict = new Dictionary<string,float>();
notesDict.Add("C", 262);
notesDict.Add("C#", 278);
notesDict.Add("D", 294);
notesDict.Add("D#", 311);
notesDict.Add("E", 330);
notesDict.Add("F", 349);
notesDict.Add("F#", 370);
notesDict.Add("G", 392);
notesDict.Add("G#", 415);
notesDict.Add("A", 440);
notesDict.Add("A#", 446);
notesDict.Add("B", 494);

string[] song = { "E","E","E","C","E","G","G","C","G","E","A","B","B","A","G","E","G","A","F","G","E","C","D","B","C","G","E","A","B","B","A","G","E","G","A","F","G","E","C","D","B","G","F#","F","D","E","G","A","C","A","C","D","G","F#","F","D","E","C","C","C","G","F#","F","D","E","G","A","C","A","C","D","D#","D","C","C","C","C","C","D","E","C","A","G","C","C","C","C","D","E","C","C","C","C","D","E","C","A","G","E","E","E","C","E","G","G","C","G","E","A","B","B","A","G","E","G","A","F","G","E","C","D","B","C","G","E","A","B","B","A","G","E","G","A","F","G","E","C","D","B","EC","G","G","A","F","F","A","B","A","A","A","G","F","E","C","A","G","EC","G","G","A","F","F","A","B","F","F","F","E","D","C","G","E","C","C","G","E","A","B","A","G#","B","G#" };
byte[] output = new byte[song.Length];

for(int i = 0; i < output.Length; i++)
{

    // output[i] = (byte)i;
    float temp;
    if (notesDict.TryGetValue(song[i], out temp)) {
        int closestFreq = 0;
        float dist = 1000000;
        for (int c = 0; c < frequencies.Length; c++) {
            if (Math.Abs(frequencies[c]-temp)<dist) {
                dist = Math.Abs(frequencies[c] - temp);
                closestFreq = c;
            }
        }
        output[i] = (byte)closestFreq;
    }
    else {
        output[i] = 0;
    }
}


output[0] = (byte)(output.Length>>8);
output[1] = (byte)(output.Length);
Console.WriteLine(output[0] +" "+ output[1]);

File.WriteAllBytes(outputPath, output);