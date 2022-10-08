% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 31"
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
nhacPhanMot = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d8 a' |
  g g f16 (e) a8 |
  d,8. d16 f8 g |
  a4 r8 bf |
  e,8. e16 e8 g |
  g2 ~ |
  g4 g8 c |
  a4. g8 |
  f a g16 (f) e8 |
  e4. e8 |
  a8. a16 f8 e |
  d2 ~ |
  d4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      a'8. a16 g8 bf |
      a4. g8 |
      e e g a
    }
    {
      f8. f16 e8 g |
      f4. e8 |
      cs cs cs cs
    }
  >>
  d4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4
  <<
    {
      a8 (bf) |
      g4. e8 |
      e g a a
    }
    {
      f8 (g) |
      e4. d8 |
      cs cs cs cs
    }
  >>
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4 a4 |
  d,8.
  <<
    {
      bf'16 a8 g |
      g4. a8 |
      f e a e
    }
    {
      g16 f8 f |
      e4. e8 |
      d d cs cs
    }
  >>
  d4 \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 r8 a |
  d (<e cs>)
  <<
    {
      f8 (g) |
      a4. bf,8 |
      e g g a
    }
    {
      d,8 (e) |
      f4. d8 |
      cs e d cs
    }
  >>
  d4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hạnh phúc thay cho kẻ lỗi lầm mà được tha thứ,
      có tội à được khoan dung.
      Hạnh phúc thay cho người Chúa không hạch tội,
      lòng trí chẳng vương gian tà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Vì thế nay con chẳng giấu Ngài tội tình con nữa,
      lỗi lầm rầy nguyện xưng ra,
      Và quyết tâm đi tự thú bao tội tình
      để Chúa thứ tha khoan hồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Vì thế ai tôn sợ Chúa Trời một lòng trung hiếu,
      khấn cầu Ngài hồi gian truân,
      Thì dẫu cho khi triều lũ dâng ngập tràn,
      chẳng có lấp xô chi họ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Vì chốn con đây ẩn náu hoài là ở nơi Chúa,
      giữ gì khỏi mọi gian nguy,
      Và khắp nơi muôn người trổi vang lời mừng
      vì Chúa cứu con an toàn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Cùng đến đây hoan hỉ nhảy mừng,
      nào người công chính, Nép vào Ngài mà vui lên.
      Và những ai tâm hồn thẳng ngay vẹn toàn,
      nào cất tiếng lên reo hò.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, Chúa đà thứ tha bao tội tình con lỗi phạm.
}

loiPhanBa = \lyricmode {
  Phúc thay người được tha thứ lỗi lầm.
}

loiPhanBon = \lyricmode {
  Chúa là chốn con dung thân,
  cứu con khỏi bước cơ cùng.
}

loiPhanNam = \lyricmode {
  Hỡi người công chính hãy mừng vui trong Chúa Trời.
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
        \line { \small "-t2 l /8TN: câu 1, 2, 3, 4 + Đ.4" }
        \line { \small "-Cn C /11TN: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-Rửa tội: câu 1, 2, 5 + Đ.2 hoặc Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 l /28TN: câu 1, 2, 5 + Đ.3" }
        \line { \small "-t4 c /4TN: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-t6 l /6TN: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-Cn B /6TN: câu 1, 2, 5 + Đ.3" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
