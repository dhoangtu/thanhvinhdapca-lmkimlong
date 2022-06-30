% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 4"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% Đổi kích thước nốt cho bè phụ
notBePhu =
#(define-music-function (font-size music) (number? ly:music?)
   (for-some-music
     (lambda (m)
       (if (music-is-of-type? m 'rhythmic-event)
           (begin
             (set! (ly:music-property m 'tweaks)
                   (cons `(font-size . ,font-size)
                         (ly:music-property m 'tweaks)))
             #t)
           #f))
     music)
   music)

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
  \key c \major
  \time 2/4
  \repeat volta 2 {
    \bar ".|:"
    \partial 4.
    e4 e8 |
    a4 \tuplet 3/2 { g8 a e } |
    d4 \tuplet 3/2 { c8 c d } |
    e4. e8 |
    b' c4 a16 b |
    b4. b8
  }
  \alternative {
    {
      d8 c4 c16 (d) |
      e2 ~ |
      e4
    }
    {
      d8 b4 d16 (e) |
      a,2 ~ |
      a4 r8 \bar "||"
    }
  }
}

nhacPhanHai = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 e4 |
  <<
    {
      c'4. c8 |
      d4 d8 c |
      b2 ~ |
      b8 gs e b' |
      a2 ~ |
      a8
    }
    {
      a4. a8 |
      b4 b8 a |
      e2 ~ |
      e8 e d d |
      c2 ~ |
      c8
    }
  >>
  \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Vạn lạy Chúa, con khấn xin Ngài,
      Đèn trời soi xét, ngày nguy khốn,
      này con kêu, Ngài thương tình giải thoát.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    Này phàm nhân cho đến bao giờ
	    lòng còn chai đá, còn ưa thích truyện hư không
	    chạy
	    \repeat unfold 4 { _ } theo điều hão huyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Hãy nhận biết Thiên Chúa yêu vì người nào trung hiếu.
	    Lời con mới vừa kêu lên,
	    Ngài thương tình trả đáp.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
      \override Lyrics.LyricText.font-shape = #'italic
	    Này người ơi, mau hãy run sợ, đừng phạm tội nữa,
	    nằm yên đó, hồi tâm đi, và
	    \repeat unfold 4 { _ } tin cậy Chúa Trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Nhiều người nói: ai sẽ ban tặng một đời hạnh phúc.
	    Phần con vẫn chỉ trông mong Thần nhan Ngài tỏa sáng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    Lòng mừng vui hơn lúc thiên hạ được mùa lúa mới,
	    nhờ ơn Chúa dủ thương con, tặng
	    \repeat unfold 4 { _ } ban đầy phước lộc.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, xin chiếu ánh Thiên Nhan trên mình chúng con.
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
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 c /10TN: cả 3 câu + Đáp" }
      }
    }
    \column {
      \left-align {
        \line { \small "-cn B /3PS: cả 3 câu + Đáp" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đáp" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanHai
        }
      \new Lyrics \lyricsto beSop \loiPhanHai
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
  }
}