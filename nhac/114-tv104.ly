% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 104"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% in số phiên khúc trên mỗi dòng
#(define (add-grob-definition grob-name grob-entry)
     (set! all-grob-descriptions
           (cons ((@@ (lily) completize-grob-entry)
                  (cons grob-name grob-entry))
                 all-grob-descriptions)))

#(add-grob-definition
    'StanzaNumberSpanner
    `((direction . ,LEFT)
      (font-series . bold)
      (padding . 1.0)
      (side-axis . ,X)
      (stencil . ,ly:text-interface::print)
      (X-offset . ,ly:side-position-interface::x-aligned-side)
      (Y-extent . ,grob::always-Y-extent-from-stencil)
      (meta . ((class . Spanner)
               (interfaces . (font-interface
                              side-position-interface
                              stanza-number-interface
                              text-interface))))))

\layout {
    \context {
      \Global
      \grobdescriptions #all-grob-descriptions
    }
    \context {
      \Score
      \remove Stanza_number_align_engraver
      \consists
        #(lambda (context)
           (let ((texts '())
                 (syllables '()))
             (make-engraver
              (acknowledgers
               ((stanza-number-interface engraver grob source-engraver)
                  (set! texts (cons grob texts)))
               ((lyric-syllable-interface engraver grob source-engraver)
                  (set! syllables (cons grob syllables))))
              ((stop-translation-timestep engraver)
                 (for-each
                  (lambda (text)
                    (for-each
                     (lambda (syllable)
                       (ly:pointer-group-interface::add-grob
                        text
                        'side-support-elements
                        syllable))
                     syllables))
                  texts)
                 (set! syllables '())))))
    }
    \context {
      \Lyrics
      \remove Stanza_number_engraver
      \consists
        #(lambda (context)
           (let ((text #f)
                 (last-stanza #f))
             (make-engraver
              ((process-music engraver)
                 (let ((stanza (ly:context-property context 'stanza #f)))
                   (if (and stanza (not (equal? stanza last-stanza)))
                       (let ((column (ly:context-property context
'currentCommandColumn)))
                         (set! last-stanza stanza)
                         (if text
                             (ly:spanner-set-bound! text RIGHT column))
                         (set! text (ly:engraver-make-grob engraver
'StanzaNumberSpanner '()))
                         (ly:grob-set-property! text 'text stanza)
                         (ly:spanner-set-bound! text LEFT column)))))
              ((finalize engraver)
                 (if text
                     (let ((column (ly:context-property context
'currentCommandColumn)))
                       (ly:spanner-set-bound! text RIGHT column)))))))
      \override StanzaNumberSpanner.horizon-padding = 10000
    }
}

stanzaReminderOff =
  \temporary \override StanzaNumberSpanner.after-line-breaking =
     #(lambda (grob)
        ;; Can be replaced with (not (first-broken-spanner? grob)) in 2.23.
        (if (let ((siblings (ly:spanner-broken-into (ly:grob-original grob))))
              (and (pair? siblings)
                   (not (eq? grob (car siblings)))))
            (ly:grob-suicide! grob)))

stanzaReminderOn = \undo \stanzaReminderOff
% kết thúc mã nguồn

% Nhạc
nhacPhanMot = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 \tuplet 3/2 { a8 g
    <<
        {
          \voiceOne
          a
        }
        \new Voice = "splitpart" {
          \voiceTwo
          \once \override NoteColumn.force-hshift = #1
          \parenthesize
          g
        }
    >>
  } |
  \oneVoice
  a8. a16 \tuplet 3/2 { d,8 f g } |
  a4. f16
  <<
    {
      \voiceOne
      g
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      f
    }
  >> |
  \oneVoice
  g4 \tuplet 3/2 { a8 g f } |
  e4 \tuplet 3/2 { a8 g a } |
  a8. a16 \tuplet 3/2 { d,8 f g } |
  a4. e16 e |
  g4 \tuplet 3/2 { a8 f e } |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d16 a' |
  a8. bf16 \tuplet 3/2 { g8 a c } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 d16 g, |
  bf4 \tuplet 3/2 { e,8 g e } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 d16 g, |
  bf4 \tuplet 3/2 { e,8 g g } |
  a4. f16 f |
  f8. e16 \tuplet 3/2 { a8 c, c } |
  d4 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 f |
  bf4 \tuplet 3/2 { g8 g a } |
  a4 \tuplet 3/2 { f8 g f } |
  e4 \tuplet 3/2 { a8 c, e } |
  d4 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  d,4. f16 (g) |
  a8. a16 \tuplet 3/2 { g8 a c } |
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBay = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  a8. d,16 \tuplet 3/2 { d8 f g } |
  a4. a16 f |
  e4 \tuplet 3/2 { g8 c, e } |
  d4 \bar "|."
}

nhacPhanTam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  a8. d,16 \tuplet 3/2 { f8 e g } |
  a4 \tuplet 3/2 { g8 f a } |
  g4 \tuplet 3/2 { a8 e f } |
  d4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy cảm tạ Chúa, cầu khấn Thánh Danh.
      Loan báo kỳ công Ngài giữa muôn dân nước.
      Hát xướng lên theo nhịp đàn ngợi khen Chúa,
      và gẫm suy sự việc Chúa đã làm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy tự hào mãi vì có Thánh Danh.
      Ai những tìm kiếm Ngài hãy may vui sướng.
      Kiếm Chúa luôn, trông nhờ quyền uy tay Chúa
      và chẳng ngưng tìm diện kiến nhan Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy cảm tạ Chúa, cầu khấn Thánh Danh.
      Loan báo kỳ công Ngài giữa muôn dân nước.
      Nhắc nhớ luôn muôn vàn kỳ công tay Chúa,
      mọi dấu thiêng, mọi điều Chúa ban truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hát lên mừng Chúa, đàn hãy tấu vang,
      suy gẫm mọi công trình Ngài đã tạo tác.
      Hãy nhớ luôn \markup { \italic "tự" } hào vì uy danh Chúa,
      hãy sướng vui, lòng kẻ kiếm trông Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Những ai cậy Chúa và dũng sức Ngài,
      luôn nhớ đừng khi ngừng tìm tôn nhan Chúa.
      Nhắc nhớ luôn muôn vàn kỳ công tay Chúa,
      mọi dấu thiêng, mọi điều Chúa ban truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
  >>
}

loiPhanHai = \lyricmode {
  
}

loiPhanBa = \lyricmode {
  
}

loiPhanBon = \lyricmode {
  
}

loiPhanNam = \lyricmode {
  
}

loiPhanSau = \lyricmode {
  
}

loiPhanBay = \lyricmode {
  
}

% Dàn trang
\paper {
  #(set-paper-size "a5")
  top-margin = 3\mm
  bottom-margin = 3\mm
  left-margin = 3\mm
  right-margin = 3\mm
  indent = #0
  #(define fonts
	 (make-pango-font-tree "Deja Vu Serif Condensed"
	 		       "Deja Vu Serif Condensed"
			       "Deja Vu Serif Condensed"
			       (/ 20 20)))
  print-page-number = ##f
  ragged-bottom = ##t
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t4 l /1TN: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-t4 l /12TN: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-t4 c /14TN: câu 1, 2, 6 + Đ.3" }
        \line { \small "-t5 l /14TN: câu 8, 9, 10 + Đ.5" }
        \line { \small "-t7 l /14TN: câu 1, 2, 6 + Đ.2" }
        \line { \small "-t5 l /15TN: câu 1, 7, 11, 12 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 c /27TN: câu 4, 5, 6 + Đ.1" }
        \line { \small "-t7 l /28TN: câu 6, 7, 14 + Đ.1" }
        \line { \small "-t5 l /31TN: câu 4, 5, 6 + Đ.4" }
        \line { \small "-t7 l /32TN: câu 4, 12, 14 + Đ.5" }
        \line { \small "-t6 /2MC: câu 8, 9, 10 + Đ.5" }
        \line { \small "-t5 /5MC: câu 5, 6, 7 + Đ.1" }
        \line { \small "-t4 /PS: câu 1, 2, 6, 7 + Đ.5" }
      }
    }
  %}
}

\score {
  <<
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #1
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.1" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanHai
        }
      \new Lyrics \lyricsto beSop \loiPhanHai
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.2" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBa
        }
      \new Lyrics \lyricsto beSop \loiPhanBa
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.3" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBon
        }
      \new Lyrics \lyricsto beSop \loiPhanBon
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.4" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanNam
        }
      \new Lyrics \lyricsto beSop \loiPhanNam
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.5" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanSau
        }
      \new Lyrics \lyricsto beSop \loiPhanSau
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.6" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBay
        }
      \new Lyrics \lyricsto beSop \loiPhanBay
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
