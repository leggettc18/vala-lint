/*
 * Copyright (c) 2016-2019 elementary LLC. (https://github.com/elementary/vala-lint)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class ValaLint.Checks.NoteCheck : Check {
    const string[] KEYWORDS = {"FIXME", "TODO"};

    public NoteCheck () {
        Object (
            single_mistake_in_line: true,
            title: _("note"),
            description: _("Checks for notes (TODO, FIXME, etc.)")
        );
    }

    public override void check (Vala.ArrayList<ParseResult?> parse_result,
                                ref Vala.ArrayList<FormatMistake?> mistake_list) {
        foreach (ParseResult r in parse_result) {
            if (r.type == ParseType.COMMENT) {
                foreach (string keyword in KEYWORDS) {
                    int index = r.text.index_of (keyword);
                    if (index > 0) {
                        /* Get message of note */
                        int index_newline = r.text.index_of ("\n", index);
                        int index_end = int.min (r.text.length, index_newline);
                        string message = r.text.slice (index + keyword.length + 1, index_end).strip ();

                        /* Get correct position of note */
                        int line_count = Utils.get_line_count (r.text[0:index]);
                        int char_count = Utils.get_char_index_in_line (r.text, index);
                        int line_pos = r.line_pos + line_count;
                        int char_pos = line_count > 0 ? char_count + 1 : r.char_pos + char_count;

                        mistake_list.add ({ this, line_pos, char_pos, @"$keyword: $message" });
                    }
                }
            }
        }
    }
}