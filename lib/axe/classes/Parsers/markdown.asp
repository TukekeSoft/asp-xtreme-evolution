﻿<%

' File: markdown.asp
' 
' AXE(ASP Xtreme Evolution) implementation of Markdown parser.
' 
' License:
' 
' This file is part of ASP Xtreme Evolution.
' Copyright (C) 2007-2009 Fabio Zendhi Nagao
' 
' ASP Xtreme Evolution is free software: you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation, either version 3 of the License, or
' (at your option) any later version.
' 
' ASP Xtreme Evolution is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
' 
' You should have received a copy of the GNU Lesser General Public License
' along with ASP Xtreme Evolution. If not, see <http://www.gnu.org/licenses/>.



' Class: Markdown
' 
' Markdown is a lightweight markup language, originally created by John Gruber
' and Aaron Swartz, which aims for maximum readability and "publishability" of
' both its input and output forms, taking many cues from existing conventions
' for marking up plain text in email. Markdown converts its marked-up text input
' to valid, well-formed XHTML and replaces left-pointing angle brackets ('<')
' and ampersands with their corresponding character entity references. Markdown
' was originally implemented in Perl by Gruber.
' 
' About:
' 
'     - This class uses the Showdown a javascript implementation of John Fraser based on John Gruber Markdown 1.0.2b7
'     - Written by Fabio Zendhi Nagao  @ November 2008
' 
class Markdown
    
    ' Property: classType
    ' 
    ' Class type.
    ' 
    ' Contains:
    ' 
    '   (string) - type
    ' 
    public classType

    ' Property: classVersion
    ' 
    ' Class version.
    ' 
    ' Contains:
    ' 
    '   (float) - version
    ' 
    public classVersion
    
    private jsWrapper
    
    private sub Class_initialize()
        classType    = "Markdown"
        classVersion = "1.0.0.0"
        
        set jsWrapper = new_Showdown()
    end sub
    
    private sub Class_terminate()
        set jsWrapper = nothing
    end sub
    
    ' Function: makeHtml
    ' 
    ' Converts Markdown into XHTML.
    ' 
    ' Parameters:
    ' 
    '     (string) - markdown
    ' 
    ' Returns:
    ' 
    '     (string) - html
    ' 
    ' Example:
    ' 
    ' (start code)
    ' 
    ' dim sMarkdown : sMarkdown = "Markdown *rocks*."
    ' dim Converter : set Converter = new Markdown
    ' 
    ' Response.write Converter.makeHtml(sMarkdown)
    ' 
    ' set Converter = nothing
    ' 
    ' (end code)
    ' 
    public function makeHtml(text)
        makeHtml = jsWrapper.makeHtml(text)
    end function
    
end class

%>
<script language="javascript" runat="server">

function new_Showdown() {
    return new Showdown.converter();
}

/*
    Copyright (c) 2007, John Fraser
    <http://www.attacklab.net/>
    All rights reserved.
    
    Original Markdown copyright (c) 2004, John Gruber
    <http://daringfireball.net/>
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:
    
    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    
    * Neither the name "Markdown" nor the names of its contributors may
      be used to endorse or promote products derived from this software
      without specific prior written permission.
    
    This software is provided by the copyright holders and contributors "as
    is" and any express or implied warranties, including, but not limited
    to, the implied warranties of merchantability and fitness for a
    particular purpose are disclaimed. In no event shall the copyright owner
    or contributors be liable for any direct, indirect, incidental, special,
    exemplary, or consequential damages (including, but not limited to,
    procurement of substitute goods or services; loss of use, data, or
    profits; or business interruption) however caused and on any theory of
    liability, whether in contract, strict liability, or tort (including
    negligence or otherwise) arising in any way out of the use of this
    software, even if advised of the possibility of such damage.
*/

var Showdown = {}

Showdown.converter = function() {
    var g_urls;
    var g_titles;
    var g_html_blocks;
    var g_list_level = 0;
    this.makeHtml = function(text) {
        g_urls = new Array();
        g_titles = new Array();
        g_html_blocks = new Array();
        text = text.replace(/~/g, "~T");
        text = text.replace(/\$/g, "~D");
        text = text.replace(/\r\n/g, "\n");
        text = text.replace(/\r/g, "\n");
        text = "\n\n" + text + "\n\n";
        text = _Detab(text);
        text = text.replace(/^[ \t]+$/mg, "");
        text = _HashHTMLBlocks(text);
        text = _StripLinkDefinitions(text);
        text = _RunBlockGamut(text);
        text = _UnescapeSpecialChars(text);
        text = text.replace(/~D/g, "$$");
        text = text.replace(/~T/g, "~");
        return text;
    }
    var _StripLinkDefinitions = function(text) {
        var text = text.replace(/^[ ]{0,3}\[(.+)\]:[ \t]*\n?[ \t]*<?(\S+?)>?[ \t]*\n?[ \t]*(?:(\n*)["(](.+?)[")][ \t]*)?(?:\n+|\Z)/gm,
        function(wholeMatch, m1, m2, m3, m4) {
            m1 = m1.toLowerCase();
            g_urls[m1] = _EncodeAmpsAndAngles(m2);
            if (m3) {
                return m3 + m4;
            } else if (m4) {
                g_titles[m1] = m4.replace(/"/g, "&quot;");
            }
            return "";
        });
        return text;
    }
    var _HashHTMLBlocks = function(text) {
        text = text.replace(/\n/g, "\n\n");
        var block_tags_a = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del"
        var block_tags_b = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math"
        text = text.replace(/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del)\b[^\r]*?\n<\/\2>[ \t]*(?=\n+))/gm, hashElement);
        text = text.replace(/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math)\b[^\r]*?.*<\/\2>[ \t]*(?=\n+)\n)/gm, hashElement);
        text = text.replace(/(\n[ ]{0,3}(<(hr)\b([^<>])*?\/?>)[ \t]*(?=\n{2,}))/g, hashElement);
        text = text.replace(/(\n\n[ ]{0,3}<!(--[^\r]*?--\s*)+>[ \t]*(?=\n{2,}))/g, hashElement);
        text = text.replace(/(?:\n\n)([ ]{0,3}(?:<([?%])[^\r]*?\2>)[ \t]*(?=\n{2,}))/g, hashElement);
        text = text.replace(/\n\n/g, "\n");
        return text;
    }
    var hashElement = function(wholeMatch, m1) {
        var blockText = m1;
        blockText = blockText.replace(/\n\n/g, "\n");
        blockText = blockText.replace(/^\n/, "");
        blockText = blockText.replace(/\n+$/g, "");
        blockText = "\n\n~K" + (g_html_blocks.push(blockText) - 1) + "K\n\n";
        return blockText;
    }
    var _RunBlockGamut = function(text) {
        text = _DoHeaders(text);
        var key = hashBlock("<hr />");
        text = text.replace(/^[ ]{0,2}([ ]?\*[ ]?){3,}[ \t]*$/gm, key);
        text = text.replace(/^[ ]{0,2}([ ]?\-[ ]?){3,}[ \t]*$/gm, key);
        text = text.replace(/^[ ]{0,2}([ ]?\_[ ]?){3,}[ \t]*$/gm, key);
        text = _DoLists(text);
        text = _DoCodeBlocks(text);
        text = _DoBlockQuotes(text);
        text = _HashHTMLBlocks(text);
        text = _FormParagraphs(text);
        return text;
    }
    var _RunSpanGamut = function(text) {
        text = _DoCodeSpans(text);
        text = _EscapeSpecialCharsWithinTagAttributes(text);
        text = _EncodeBackslashEscapes(text);
        text = _DoImages(text);
        text = _DoAnchors(text);
        text = _DoAutoLinks(text);
        text = _EncodeAmpsAndAngles(text);
        text = _DoItalicsAndBold(text);
        text = text.replace(/  +\n/g, " <br />\n");
        return text;
    }
    var _EscapeSpecialCharsWithinTagAttributes = function(text) {
        var regex = /(<[a-z\/!$]("[^"]*"|'[^']*'|[^'">])*>|<!(--.*?--\s*)+>)/gi;
        text = text.replace(regex,
        function(wholeMatch) {
            var tag = wholeMatch.replace(/(.)<\/?code>(?=.)/g, "$1`");
            tag = escapeCharacters(tag, "\\`*_");
            return tag;
        });
        return text;
    }
    var _DoAnchors = function(text) {
        text = text.replace(/(\[((?:\[[^\]]*\]|[^\[\]])*)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/g, writeAnchorTag);
        text = text.replace(/(\[((?:\[[^\]]*\]|[^\[\]])*)\]\([ \t]*()<?(.*?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/g, writeAnchorTag);
        text = text.replace(/(\[([^\[\]]+)\])()()()()()/g, writeAnchorTag);
        return text;
    }
    var writeAnchorTag = function(wholeMatch, m1, m2, m3, m4, m5, m6, m7) {
        if (m7 == undefined) m7 = "";
        var whole_match = m1;
        var link_text = m2;
        var link_id = m3.toLowerCase();
        var url = m4;
        var title = m7;
        if (url == "") {
            if (link_id == "") {
                link_id = link_text.toLowerCase().replace(/ ?\n/g, " ");
            }
            url = "#" + link_id;
            if (g_urls[link_id] != undefined) {
                url = g_urls[link_id];
                if (g_titles[link_id] != undefined) {
                    title = g_titles[link_id];
                }
            } else {
                if (whole_match.search(/\(\s*\)$/m) > -1) {
                    url = "";
                } else {
                    return whole_match;
                }
            }
        }
        url = escapeCharacters(url, "*_");
        var result = "<a href=\"" + url + "\"";
        if (title != "") {
            title = title.replace(/"/g, "&quot;");
            title = escapeCharacters(title, "*_");
            result += " title=\"" + title + "\"";
        }
        result += ">" + link_text + "</a>";
        return result;
    }
    var _DoImages = function(text) {
        text = text.replace(/(!\[(.*?)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/g, writeImageTag);
        text = text.replace(/(!\[(.*?)\]\s?\([ \t]*()<?(\S+?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/g, writeImageTag);
        return text;
    }
    var writeImageTag = function(wholeMatch, m1, m2, m3, m4, m5, m6, m7) {
        var whole_match = m1;
        var alt_text = m2;
        var link_id = m3.toLowerCase();
        var url = m4;
        var title = m7;
        if (!title) title = "";
        if (url == "") {
            if (link_id == "") {
                link_id = alt_text.toLowerCase().replace(/ ?\n/g, " ");
            }
            url = "#" + link_id;
            if (g_urls[link_id] != undefined) {
                url = g_urls[link_id];
                if (g_titles[link_id] != undefined) {
                    title = g_titles[link_id];
                }
            } else {
                return whole_match;
            }
        }
        alt_text = alt_text.replace(/"/g, "&quot;");
        url = escapeCharacters(url, "*_");
        var result = "<img src=\"" + url + "\" alt=\"" + alt_text + "\"";
        title = title.replace(/"/g, "&quot;");
        title = escapeCharacters(title, "*_");
        result += " title=\"" + title + "\"";
        result += " />";
        return result;
    }
    var _DoHeaders = function(text) {
        text = text.replace(/^(.+)[ \t]*\n=+[ \t]*\n+/gm,
        function(wholeMatch, m1) {
            return hashBlock("<h1>" + _RunSpanGamut(m1) + "</h1>");
        });
        text = text.replace(/^(.+)[ \t]*\n-+[ \t]*\n+/gm,
        function(matchFound, m1) {
            return hashBlock("<h2>" + _RunSpanGamut(m1) + "</h2>");
        });
        text = text.replace(/^(\#{1,6})[ \t]*(.+?)[ \t]*\#*\n+/gm,
        function(wholeMatch, m1, m2) {
            var h_level = m1.length;
            return hashBlock("<h" + h_level + ">" + _RunSpanGamut(m2) + "</h" + h_level + ">");
        });
        return text;
    }
    var _ProcessListItems;
    var _DoLists = function(text) {
        text += "~0";
        var whole_list = /^(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/gm;
        if (g_list_level) {
            text = text.replace(whole_list,
            function(wholeMatch, m1, m2) {
                var list = m1;
                var list_type = (m2.search(/[*+-]/g) > -1) ? "ul": "ol";
                list = list.replace(/\n{2,}/g, "\n\n\n");;
                var result = _ProcessListItems(list);
                result = result.replace(/\s+$/, "");
                result = "<" + list_type + ">" + result + "</" + list_type + ">\n";
                return result;
            });
        } else {
            whole_list = /(\n\n|^\n?)(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/g;
            text = text.replace(whole_list,
            function(wholeMatch, m1, m2, m3) {
                var runup = m1;
                var list = m2;
                var list_type = (m3.search(/[*+-]/g) > -1) ? "ul": "ol";
                var list = list.replace(/\n{2,}/g, "\n\n\n");;
                var result = _ProcessListItems(list);
                result = runup + "<" + list_type + ">\n" + result + "</" + list_type + ">\n";
                return result;
            });
        }
        text = text.replace(/~0/, "");
        return text;
    }
    _ProcessListItems = function(list_str) {
        g_list_level++;
        list_str = list_str.replace(/\n{2,}$/, "\n");
        list_str += "~0";
        list_str = list_str.replace(/(\n)?(^[ \t]*)([*+-]|\d+[.])[ \t]+([^\r]+?(\n{1,2}))(?=\n*(~0|\2([*+-]|\d+[.])[ \t]+))/gm,
        function(wholeMatch, m1, m2, m3, m4) {
            var item = m4;
            var leading_line = m1;
            var leading_space = m2;
            if (leading_line || (item.search(/\n{2,}/) > -1)) {
                item = _RunBlockGamut(_Outdent(item));
            } else {
                item = _DoLists(_Outdent(item));
                item = item.replace(/\n$/, "");
                item = _RunSpanGamut(item);
            }
            return "<li>" + item + "</li>\n";
        });
        list_str = list_str.replace(/~0/g, "");
        g_list_level--;
        return list_str;
    }
    var _DoCodeBlocks = function(text) {
        text += "~0";
        text = text.replace(/(?:\n\n|^)((?:(?:[ ]{4}|\t).*\n+)+)(\n*[ ]{0,3}[^ \t\n]|(?=~0))/g,
        function(wholeMatch, m1, m2) {
            var codeblock = m1;
            var nextChar = m2;
            codeblock = _EncodeCode(_Outdent(codeblock));
            codeblock = _Detab(codeblock);
            codeblock = codeblock.replace(/^\n+/g, "");
            codeblock = codeblock.replace(/\n+$/g, "");
            codeblock = "<pre><code>" + codeblock + "\n</code></pre>";
            return hashBlock(codeblock) + nextChar;
        });
        text = text.replace(/~0/, "");
        return text;
    }
    var hashBlock = function(text) {
        text = text.replace(/(^\n+|\n+$)/g, "");
        return "\n\n~K" + (g_html_blocks.push(text) - 1) + "K\n\n";
    }
    var _DoCodeSpans = function(text) {
        text = text.replace(/(^|[^\\])(`+)([^\r]*?[^`])\2(?!`)/gm,
        function(wholeMatch, m1, m2, m3, m4) {
            var c = m3;
            c = c.replace(/^([ \t]*)/g, "");
            c = c.replace(/[ \t]*$/g, "");
            c = _EncodeCode(c);
            return m1 + "<code>" + c + "</code>";
        });
        return text;
    }
    var _EncodeCode = function(text) {
        text = text.replace(/&/g, "&amp;");
        text = text.replace(/</g, "&lt;");
        text = text.replace(/>/g, "&gt;");
        text = escapeCharacters(text, "\*_{}[]\\", false);
        return text;
    }
    var _DoItalicsAndBold = function(text) {
        text = text.replace(/(\*\*|__)(?=\S)([^\r]*?\S[*_]*)\1/g, "<strong>$2</strong>");
        text = text.replace(/(\*|_)(?=\S)([^\r]*?\S)\1/g, "<em>$2</em>");
        return text;
    }
    var _DoBlockQuotes = function(text) {
        text = text.replace(/((^[ \t]*>[ \t]?.+\n(.+\n)*\n*)+)/gm,
        function(wholeMatch, m1) {
            var bq = m1;
            bq = bq.replace(/^[ \t]*>[ \t]?/gm, "~0");
            bq = bq.replace(/~0/g, "");
            bq = bq.replace(/^[ \t]+$/gm, "");
            bq = _RunBlockGamut(bq);
            bq = bq.replace(/(^|\n)/g, "$1  ");
            bq = bq.replace(/(\s*<pre>[^\r]+?<\/pre>)/gm,
            function(wholeMatch, m1) {
                var pre = m1;
                pre = pre.replace(/^  /mg, "~0");
                pre = pre.replace(/~0/g, "");
                return pre;
            });
            return hashBlock("<blockquote>\n" + bq + "\n</blockquote>");
        });
        return text;
    }
    var _FormParagraphs = function(text) {
        text = text.replace(/^\n+/g, "");
        text = text.replace(/\n+$/g, "");
        var grafs = text.split(/\n{2,}/g);
        var grafsOut = new Array();
        var end = grafs.length;
        for (var i = 0; i < end; i++) {
            var str = grafs[i];
            if (str.search(/~K(\d+)K/g) >= 0) {
                grafsOut.push(str);
            }
            else if (str.search(/\S/) >= 0) {
                str = _RunSpanGamut(str);
                str = str.replace(/^([ \t]*)/g, "<p>");
                str += "</p>"
                grafsOut.push(str);
            }
        }
        end = grafsOut.length;
        for (var i = 0; i < end; i++) {
            while (grafsOut[i].search(/~K(\d+)K/) >= 0) {
                var blockText = g_html_blocks[RegExp.$1];
                blockText = blockText.replace(/\$/g, "$$$$");
                grafsOut[i] = grafsOut[i].replace(/~K\d+K/, blockText);
            }
        }
        return grafsOut.join("\n\n");
    }
    var _EncodeAmpsAndAngles = function(text) {
        text = text.replace(/&(?!#?[xX]?(?:[0-9a-fA-F]+|\w+);)/g, "&amp;");
        text = text.replace(/<(?![a-z\/?\$!])/gi, "&lt;");
        return text;
    }
    var _EncodeBackslashEscapes = function(text) {
        text = text.replace(/\\(\\)/g, escapeCharacters_callback);
        text = text.replace(/\\([`*_{}\[\]()>#+-.!])/g, escapeCharacters_callback);
        return text;
    }
    var _DoAutoLinks = function(text) {
        text = text.replace(/<((https?|ftp|dict):[^'">\s]+)>/gi, "<a href=\"$1\">$1</a>");
        text = text.replace(/<(?:mailto:)?([-.\w]+\@[-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+)>/gi,
        function(wholeMatch, m1) {
            return _EncodeEmailAddress(_UnescapeSpecialChars(m1));
        });
        return text;
    }
    var _EncodeEmailAddress = function(addr) {
        function char2hex(ch) {
            var hexDigits = '0123456789ABCDEF';
            var dec = ch.charCodeAt(0);
            return (hexDigits.charAt(dec >> 4) + hexDigits.charAt(dec & 15));
        }
        var encode = [
            function(ch) {
                return "&#" + ch.charCodeAt(0) + ";";
            },
            function(ch) {
                return "&#x" + char2hex(ch) + ";";
            },
            function(ch) {
                return ch;
            }
        ];
        addr = "mailto:" + addr;
        addr = addr.replace(/./g,
        function(ch) {
            if (ch == "@") {
                ch = encode[Math.floor(Math.random() * 2)](ch);
            } else if (ch != ":") {
                var r = Math.random();
                ch = (
                r > .9 ? encode[2](ch) : r > .45 ? encode[1](ch) : encode[0](ch));
            }
            return ch;
        });
        addr = "<a href=\"" + addr + "\">" + addr + "</a>";
        addr = addr.replace(/">.+:/g, "\">");
        return addr;
    }
    var _UnescapeSpecialChars = function(text) {
        text = text.replace(/~E(\d+)E/g,
        function(wholeMatch, m1) {
            var charCodeToReplace = parseInt(m1);
            return String.fromCharCode(charCodeToReplace);
        });
        return text;
    }
    var _Outdent = function(text) {
        text = text.replace(/^(\t|[ ]{1,4})/gm, "~0");
        text = text.replace(/~0/g, "")
        return text;
    }
    var _Detab = function(text) {
        text = text.replace(/\t(?=\t)/g, "    ");
        text = text.replace(/\t/g, "~A~B");
        text = text.replace(/~B(.+?)~A/g,
        function(wholeMatch, m1, m2) {
            var leadingText = m1;
            var numSpaces = 4 - leadingText.length % 4;
            for (var i = 0; i < numSpaces; i++) leadingText += " ";
            return leadingText;
        });
        text = text.replace(/~A/g, "    ");
        text = text.replace(/~B/g, "");
        return text;
    }
    var escapeCharacters = function(text, charsToEscape, afterBackslash) {
        var regexString = "([" + charsToEscape.replace(/([\[\]\\])/g, "\\$1") + "])";
        if (afterBackslash) {
            regexString = "\\\\" + regexString;
        }
        var regex = new RegExp(regexString, "g");
        text = text.replace(regex, escapeCharacters_callback);
        return text;
    }
    var escapeCharacters_callback = function(wholeMatch, m1) {
        var charCodeToEscape = m1.charCodeAt(0);
        return "~E" + charCodeToEscape + "E";
    }
}

</script>
