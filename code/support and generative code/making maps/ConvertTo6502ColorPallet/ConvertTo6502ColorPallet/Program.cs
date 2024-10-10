// See https://aka.ms/new-console-template for more information
using System.Net.NetworkInformation;
using System.Drawing;
using System.Numerics;
using System.IO;
using System.Text;

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
string imageName = "firstMapTileSetWithDad";
string imageFileFormat = "png";
string outputImageName = imageName + "firstMapTileSetWithDadConverted";


Bitmap bitmapNormal = new Bitmap("C:\\Users\\breck\\Pictures\\6502\\" + imageName + "." + imageFileFormat);
Bitmap bitmap = new Bitmap(bitmapNormal.Width, bitmapNormal.Height);
Color clr;

for (int x = 0; x < bitmapNormal.Width; x++)
{

    for (int y = 0; y < bitmapNormal.Height; y++)
    {
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
        bitmap.SetPixel(x, y, pallet[closest]);
    }
}

bitmap.Save("C:\\Users\\breck\\Pictures\\6502\\" + outputImageName + "." + imageFileFormat);
