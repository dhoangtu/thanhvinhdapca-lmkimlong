% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 85"
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
  \partial 8 a16 bf |
  a4 \tuplet 3/2 { f8 g a } |
  c,4. c16 g' |
  g4 \tuplet 3/2 { g8 e c' } |
  c4 r8 c |
  d4 \tuplet 3/2 { bf8 bf bf } |
  c8. d16 \tuplet 3/2 { g,8 g bf } |
  a4 r8 g |
  a4 \tuplet 3/2 { e8 f g } |
  c,8. c16 \tuplet 3/2 { e8 e g } |
  f4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'4. a16 bf |
      g4 \tuplet 3/2 { c,8 g' e } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f4. f16 d |
      c4 \tuplet 3/2 { a8 bf c } |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'4. bf16 a |
      g4 \tuplet 3/2 { c,8 g' g } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f4. g16 f |
      c4 \tuplet 3/2 { a8 bf c } |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'4. bf16 g |
      g8. g16 \tuplet 3/2 { c8 e, e } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f4. g16 f |
      e8. e16 \tuplet 3/2 { d8 c c } |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f16 e |
  f4. c16
  <<
    {
      f |
      a4. f8 |
      bf4 \tuplet 3/2 { g8 a bf } |
      c8. g16 \tuplet 3/2 { g8 a g } |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f16 |
      f4. ef8 |
      d4 \tuplet 3/2 { e8 f f } |
      a8. e16 \tuplet 3/2 { e8 f c } |
      a2 ~ |
      a4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin lắng tai và mau đáp lời,
      Vì thân con đơn nghèo túng quẫn.
      Xin Chúa bảo toàn mạng con
      vẫn một lòng hiếu trung.
      Xin cứu bầy tôi của Ngài hằng trọn niềm mến tin.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin xót thương, này con suốt ngày hằng kêu lên:
      Muôn lạy Đức Chúa.
      Xin khiến lòng hèn mọn con mãi thỏa tình sướng vui.
      Ôi Chúa, này con hướng vọng hồn con lên Chúa luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Thiên Chúa luôn từ bi hải hà,
      giầu yêu thương cho người khấn ước.
      Xin Chúa niệm tình lặng nghe tiếng lòng này khấn xin.
      Bao tiếng hồn con khẩn cầu, nguyện lưu tâm, Chúa ơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Muôn sắc dân Ngài đã tác thành,
      về nơi đây suy phục bái kính.
      Ơn Chúa trọng đại dường bao, chỉ Ngài là Chúa thôi.
      Tay Chúa từng đã tác thành ngàn uy công, Chúa ơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Nhưng Chúa ơi, Ngài bao tốt lành,
      đầy khoan dung, luôn chậm oán thán.
      Ôi Chúa thực giầu tình thương, vẫn một lòng tín trung.
      Xin Chúa từ bi đoái nhìn và xin thương xót con.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, xin lắng tai và đáp lời con.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, Chúa nhân hậu và luôn khoan hồng.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, Chúa chậm giận và rất giầu tình thương.
}

loiPhanNam = \lyricmode {
  Xin dạy con đường lối Chúa, lạy Chúa,
  để con vững bước theo chân lý của Ngài.
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
        \line { \small "-t3 c /4TN: caau 1, 2, 3 + Đ.1" }
        \line { \small "-Cn A /16TN: câu 3, 4, 5 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t4 l /27TN: câu 2, 3, 4 + Đ.3" }
        \line { \small "-t7 sau lễ Tro: câu 1, 2, 3 + Đ.4" }
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
