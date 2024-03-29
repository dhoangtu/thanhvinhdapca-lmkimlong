% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 8"
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
  \key c \major
  \time 2/4
  \partial 8 a8 |
  c8. e,16 a8 a |
  g2 |
  a8 d, e f |
  g8. g16 e (d) c8 |
  c2 ~ |
  c4 e8 e |
  d8. d16 a'8 fs |
  g4 r8 g |
  c8 c f, f |
  g8. f16 d8 f |
  g e4 d8 |
  c4 r8 \bar "||" \break
  
  <<
    {
      g'8 |
      c8. e,16 a8 a |
      g2 |
      a8 d, f f |
      g8. g16
    }
    {
      c,8 |
      e8. c16 f8 f |
      e2 |
      d8 b d c |
      b8. b16
    }
  >>
  <<
    {
      \voiceOne
      e16 (d) c8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b8 c8
    }
  >>
  \oneVoice
  c2 ~ |
  c4 \bar "|." \break
  
  \partial 8
  <<
    {
      c'8 |
      g g e e |
      f4. e8 |
      d8. f16 g8 g
    }
    {
      e8 |
      d d c c |
      d4. c8 |
      b8. a16 b8 b
    }
  >>
  c4 r8 \bar "|."
  
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      g8 |
      c8. e,16 a8 a |
      g2 |
      a8 d, f f |
      g8. g16
    }
    {
      c,8 |
      e8. c16 f8 f |
      e2 |
      d8 b d c |
      b8. b16
    }
  >>
  <<
    {
      \voiceOne
      e16 (d) c8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b8 c8
    }
  >>
  \oneVoice
  c2 ~ |
  c4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      c8 |
      g g e e |
      f4. e8 |
      d8. f16 g8 g
    }
    {
      e8 |
      d d c c |
      d4. c8 |
      b8. a16 b8 b
    }
  >>
  c4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Lạy Chúa là Chúa chúng con,
      lẫy lừng thay danh Chúa khắp trên địa cầu.
      Uy danh Ngài vượt quá trời cao,
      Ngài đã khiến miệng trẻ thơ
      vang lời ngợi khen chống quân thù.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Lạy Chúa là Chúa chúng con,
	    lẫy lừng thay danh Chúa khắp trên địa cầu.
	    Ôi con người nào có là chi,
	    Ngài nhớ tới và bận tâm
	    cho dù phàm nhân có ra gì.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Nhìn cõi trời Chúa tác sinh,
	    xếp đặt muôn tinh tú, ánh trăng rạng ngời.
	    Ôi con người nào có là chi,
	    Ngài nhớ tới và bận tâm
	    cho dù phàm nhân có ra gì.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Người thế được cất nhắc lên,
	    sánh hàng cùng thần minh chẳng thua gì nhiều.
	    Ban vinh dự làm mũ triều thiên,
	    đặt thống lãnh mọi kỳ công tay quyền năng Chúa đã tạo thành.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Được Chúa gọi đến dưới chân các loại bò chiên
	    với thú nơi ruộng đồng, bao chim trời
	    cùng cá đại dương và hết những loài dọc ngang bơi lội
	    tung tăng giữa ba đào.
    }
  >>
  
  \stanzaReminderOff
	\set stanza = "Đ.1"
  Lạy Chúa là Chúa chúng con,
  lẫy lừng thay danh Chúa khắp trên địa cầu.
  
  \set stanza = "Đ.2"
  Chúa cho con người làm chủ công trình tay Chúa sáng tạo.
  
}

loiPhanHai = \lyricmode {
  Lạy Chúa là Chúa chúng con,
  lẫy lừng thay danh Chúa khắp trên địa cầu.
}

loiPhanBa = \lyricmode {
  Chúa cho con người làm chủ công trình tay Chúa sáng tạo.
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
}

\markup {
  \vspace #1
  \fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t3 l /1TN: câu 2,4,5 + Đ.2" }
        \line { \small "-t3 l /3TN: câu 3,4,,5 + Đ.1" }
        \line { \small "-t7 c /28TN: câu 1,3,4 + " }
      }
    }
    \column {
      \left-align {
        \line { \small "-t5 /PS: câu 2,4,5 + Đ.1" }
        \line { \small "-lễ Chúa Ba Ngôi C: câu 3,4,5 + Đ.1" }
        \line { \small "-lễ khi Rửa Tội: câu 3,4,5 + Đ.1" }
        \line { \small "-dịp đầu năm: câu 3,4,5 + Đ.1" }
      }
    }
  }
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
%{
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
%}
