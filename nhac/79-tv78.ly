% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 78"
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
  \partial 4 d4 |
  a'4. g16 f |
  g8 g a f |
  e4 r8 e16 g |
  f8 d f (g) |
  a4 r8 bf16 a |
  a8 e g f |
  d2 ~ |
  d4 r8 c16 c |
  f8 e f g |
  a2 |
  g8 f d (f) |
  g4 r8 a16 a |
  f8 g a f |
  e4. d8 |
  e g4 a8 |
  a4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      a'4 g8 a |
      d, (f) g a |
      g4. a8 |
      a e e f
    }
    {
      f4 e8 f |
      bf, (d) e f |
      e4. f8 |
      d d cs cs
    }
  >>
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      a'4. f8 |
      g a f4 |
      e4. e8 |
      a, f' f (e)
    }
    {
      f4. d8 |
      e f d4 |
      a4. a8 |
      a d d (cs)
    }
  >>
  d2 ~ |
  d4 \bar "|."
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      a'4. g8 |
      e e16 (f) a8 a |
      g4. e8 |
      f e a4
    }
    {
      f4. e8 |
      c c16 (d) f8 f |
      e4. a,8 |
      d d cs4
    }
  >>
  d2 ~ |
  d4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Lạy Chúa, dân ngoại xâm lăng lãnh địa Ngài,
      làm uế nhơ cả đền thánh,
      biến Gia -- liêm thành đống tro tàn.
      Liệng tử thi của bầy tôi Chúa cho chim trời ăn,
      ném xác kẻ trung hiếu của Ngài làm mồi cho dã thú.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Ngài thấy: quanh thành Gia -- liêm máu tuôn tràn,
      kẻ chết không người chôn cất.
      Máu con dân Ngài đổ chan hòa.
      Này đoàn con bị người lân lý khinh mạn dể duôi.
      Chúa nỡ giận cho đến bao giờ,
      lòng hờn ghen cứ cháy.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Tội lỗi của tiền nhân sao nhớ chi hoài,
      mà cứ sửa phạt con cháu.
      Chúng con nay cùng khốn trăm chiều.
      Lạy Ngài xin dủ thương cứu rỗi, dung tha đoàn con.
      Kíp nhớ lại danh giá của Ngài mà làm cho sáng chói.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Lạy Chúa, bao tù nhân rên xiết đêm ngày,
      vọng thấu lên tận tai Chúa.
      Cứu sinh ai bị án tử hình.
      Còn đoàn chiên Ngài thương chăn dắt.
      Nay xin tạ ơn,
      mãi mãi đoàn con sẽ dâng lời mà ngợi khen kính chúc.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa xin chiếu tỏa trên chúng con ánh sáng lòng từ bi Ngài.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, để danh Chúa rạng ngời, xin giải thoát chúng con.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, xin đừng xử với chúng con như chúng con đáng tội.
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
        \line { \small "-t4 l /8TN: câu 3, 4 + Đ.1" }
        \line { \small "-t5 c /12TN: câu 1, 2, 3 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 c /17TN: câu 3, 4 + Đ.2" }
        \line { \small "-t6 l /26TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t2 /2MC: câu 3, 4 + Đ.3" }
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
