using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LitJson;
using System.IO;
using System.Diagnostics;
using System.Collections;
using System.Collections.Specialized;
using System.Reflection;


namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            string strFilename="E:\\FolderShare\\Home\\RentalData\\Cleopatra_20080321.txt";
            StreamReader sr = new StreamReader(strFilename);
            JSONWrapper objJSON = new JSONWrapper();
            string strRawJSON;

            strRawJSON = sr.ReadToEnd();
            if (strRawJSON.StartsWith("("))
            {
                strRawJSON = strRawJSON.Substring(1,strRawJSON.Length-4);
            }

            objJSON.LoadHouseInfo(strRawJSON);
        }
    }
}


public class JSONWrapper
{
    public void DumpFields(JsonData objJSON, int nDepth)
    {
        IDictionary iDict;
        int nCount;
        JsonType jsonTyp;
        int nTabs;

        iDict = objJSON as IDictionary;
        nCount = iDict.Count;

        foreach (string strField in iDict.Keys)
        {
            jsonTyp = objJSON[strField].GetJsonType();
            switch (jsonTyp)
            {
                case JsonType.Array:
                    for (nTabs = 1; nTabs < nDepth; nTabs++)
                    {
                        Debug.Write("\t");
                    }
                    Debug.Write(strField + " : " + objJSON[strField].Count + " element array\n");
                    foreach (JsonData objArrayElement in objJSON[strField])
                    {
                        DumpFields(objArrayElement, nDepth+1);
                        Debug.WriteLine("");
                    }
                    break;
                case JsonType.Object:
                    for (nTabs = 1; nTabs < nDepth; nTabs++)
                    {
                        Debug.Write("\t");
                    }
                    Debug.Write(strField + " : Object\n");
                    DumpFields (objJSON[strField], nDepth+1);
                    break;
                default:
                    for (nTabs = 1; nTabs < nDepth; nTabs++)
                    {
                        Debug.Write("\t");
                    }
                    Debug.Write(strField + " ("+jsonTyp+") : " + objJSON[strField] + "\n");
                    break;
            }
        }
    }

    public void LoadHouseInfo (string json_text)
    {
        JsonData data = JsonMapper.ToObject (json_text);
        int nCount;
        int nIndex;
        IDictionary iDict;
        JsonData parcels;
        JsonType enType;
        Type sysType;

        DumpFields(data, 1);

        double longitude = (double)data["parcels"][0]["longitude"];
    }
}

      