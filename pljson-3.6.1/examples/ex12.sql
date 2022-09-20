/*
This software has been released under the MIT license:

  Copyright (c) 2009 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/
/* Using the pretty-print with anydata */
set serveroutput on;
declare
  obj pljson;
begin
  obj := pljson('{"a": "true"}');
  --directly from pljson_printer
  dbms_output.put_line(pljson_printer.pretty_print_any(pljson_ext.get_json_element(obj, 'a')));
  --from pljson_ext varchar2
  dbms_output.put_line(pljson_ext.pp(obj, 'a'));
  --from pljson_ext dbms_output.put_line
  pljson_ext.pp(obj, 'a');
  --from pljson_ext htp.print
  --pljson_ext.pp_htp(obj, 'a');
end;
/
