byte[] randomBytes = new byte[256];
Random rand=new Random();
for(int i = 0; i < randomBytes.Length; i++)
{
    randomBytes[i] = (byte)rand.Next(0, 255);
}

File.WriteAllBytes("C:\\Users\\breck\\Documents\\_CIRCUITS AND 6502\\programs\\randomNumbers.bin", randomBytes);