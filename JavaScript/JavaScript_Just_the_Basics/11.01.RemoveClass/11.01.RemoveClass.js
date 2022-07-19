function removeClass (allClassNames, classNameToRemove)
/* 'allClassNames': a string containing all the class names */
/* 'classNameToRemove': a string containing the class name you want to remove */
/* returns: a string containing the class names without the removed one */
  {
  /* remove all instances of 'classNameToRemove' plus following whitespace: */
  var s = allClassNames.replace (RegExp (classNameToRemove + "\\s*", "g"), "");
  
  /* remove any remaining whitespace at end of string: */
  return s.replace (/\s*$/, "");
  }
