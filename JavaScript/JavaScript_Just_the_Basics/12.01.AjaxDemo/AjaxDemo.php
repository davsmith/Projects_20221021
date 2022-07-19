<?php
   header ('Content-Type: application/xml');

   echo '<?xml version="1.0"?>'."\n";

   // start root element:
   echo "<weather>\n";

   // get current weather:
   $theURL="http://weather.noaa.gov/weather/current/KSFO.html";
   if (!($contents = file_get_contents ($theURL)))
      {
      echo '<error>Error: Could not open weather site ('.$theURL.").</error>\n</weather>\n";
      exit;
      }

   /* "Temperature"[3], "Conditions"[i.e. "Weather"][2], "Wind"[1] */

   // pattern to be matched:
   $pattern = '<td>[^<]*</td><td align="right">[^<]*</td><td>([^<]*)</td><td>[^<]*</td><td align="left">([^<]*)</td><td>[^<]*</td><td>([^<]*)</td>';

   // look for pattern in website contents:
   $patternFound = false;
   if (ereg ($pattern, $contents, $result))
      $patternFound = true;

   // write temperature:
   echo '<temp>';
   if ($patternFound)
      {
      echo $result[3]."</temp>\n";
      }
   else
      {
      echo "can't find temperature</temp>\n";
      };

   // write conditions:
   echo '<cond>';
   if ($patternFound)
      {
      echo $result[2]."</cond>\n";
      }
   else
      {
      echo "can't find conditions</cond>\n";
      };

   // write wind:
   echo '<wind>';
   if ($patternFound)
      {
      echo $result[1]."</wind>\n";
      }
   else
      {
      echo "can't find wind</wind>\n";
      };

   // close root element:
   echo "</weather>\n";
?>
