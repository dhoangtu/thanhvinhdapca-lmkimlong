% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 9A"
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
  c8. c16 e8 d |
  f4. fs8 |
  g8. a16 g8 e |
  d4 r8 a' |
  g8. g16 g8 a |
  c4. b8 |
  d16 (e) d8 e, f |
  g4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 c8 a |
  g4. <a c,>8 |
  <<
    {
      \voiceOne
      d,8 (g) e (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b4 b
    }
  >>
  \oneVoice
  c2 ~ |
  c4 r \bar "|."
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 g4 |
  <<
    {
      c4. c8 |
      a (g) e (f) |
      g4. b8 |
      a g
    }
    {
      e4. e8 |
      f (e) c (d) |
      b4. d8 |
      f e
    }
  >>
  <<
    {
      \voiceOne
      a8 _(b)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      d,4
    }
  >>
  \oneVoice
  <c' e,>2 ~ |
  <c e,>4 r4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 g4 |
  <<
    {
      c4. a8 |
      d e
    }
    {
      e,4. c8 |
      f g
    }
  >>
  <<
    {
      \voiceOne
      a16 (c) a8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      f8 f
    }
  >>
  \oneVoice
  <<
    {
      g4 f8 g |
      d4. e8
    }
    {
      e4 d8 c |
      b4. b8
    }
  >>
  c2 ~ |
  c4 r4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
	    Một lòng cảm tạ Chúa, truyền rao các uy công Ngài,
	    hoan lạc dạo đàn ca hát mừng Chúa cao trọng vô biên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Địch thù con chạy trốn, mạng vong trước tôn nhan Ngài,
      Chính Ngài diệt bọn gian ác, mờ xóa tên tuổi thiên thu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	   Ngài diệt quân tàn ác vùi tên tuổi đi muôn đời.
	   Hố họ đào họ sa xuống,
	   Sập bẫy chính bọn họ giăng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Phần Ngài minh trị mãi,
	    Đặt ngai xét xử muôn đời,
	    Chính trực điều hành muôn nước,
	    Xử xét gian trần công minh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Ngài tựa như thành quách chở che những ai cơ cùng.
	    Ai tìm cậy nhờ Danh Chúa, thì Chúa không hề bỏ rơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
	    Nào đàn ca mừng Chúa, truyền rao các uy công Ngài,
	    Chúa trị tội kẻ lưu huyết, mà nhớ ai nghèo khổ luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
	    Bọn họ sa vào lưới họ giăng mắc ra hại người.
	    Kẻ nghèo nào bị quyên lãng, người đói không tuyệt vọng đâu.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa công minh xét xử gian trần.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, Chúa không bỏ rơi những ai tìm Nhan Chúa.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, này con hớn hở reo mừng vì ơn Ngài cứu độ.
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
  ragged-bottom = ##t
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
        \line { \small "-t7 c /18TN: câu 4,5,6 + Đ.2" }
        \line { \small "-t6 l /2TN: câu 1,3,4 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 l /33TN: câu 1,2,7 + Đ.3" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
