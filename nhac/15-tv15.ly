% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 15"
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
  \key bf \major
  \time 2/4
  \partial 4 \tuplet 3/2 { g8 a fs } |
  g4. d8 |
  bf'4 \tuplet 3/2 { bf8 g bf } |
  c4. c8 |
  d4 \tuplet 3/2 { g,8 g a } |
  bf4. g8 
  a4 \tuplet 3/2 { d,8 d d } |
  a'4. fs8 |
  g2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b4 \tuplet 3/2 { b8 g a } |
      d,4 \tuplet 3/2 { d8 d d } |
      a'4. fs8 |
      g4 \bar ".|"
    }
    {
      g4 \tuplet 3/2 { g8 d c } |
      b4 \tuplet 3/2 { b8 b b } |
      c4. d8 |
      b4
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b4 \tuplet 3/2 { b8 g a } |
      a8. a16 \tuplet 3/2 { d,8 a' fs } |
      g2 ~ |
      g4 \bar "|."
    }
    {
      g4 \tuplet 3/2 { g8 e c } |
      d8. c16 \tuplet 3/2 { b8 c d } |
      b2 ~ |
      b4
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b4. c16 b |
      b4. a8 |
      c4 \tuplet 3/2 { c8 a c } |
      d4. d8 |
      g,2 ~ |
      g4 \bar "|."
    }
    {
      g4. a16 g |
      g4. g8 |
      fs4 \tuplet 3/2 { e8 e a } |
      fs4. fs8 |
      g2 ~ |
      g4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin giữ gìn con, lạy Chúa, con tìm ẩn thân bên Chúa,
      Ngài là Thiên Chúa của con, là nguồn hạnh phúc đời con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Bao lớp thần minh tàn phá, thiên hạ đổ xô theo mãi.
	    Nguyện chẳng dây máu họ dâng, miệng này thề tránh niệm danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Đây sản nghiệp con là Chúa, sinh mạng con trong tay Chúa.
	    Phần tuyệt luân đã về con, được Ngài tặng chén lộc ân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Đây sản nghiệp con là Chúa, sinh mạng con trong tay Chúa.
	    Đặt Ngài ở trước mặt luôn, gần Ngài là hết chuyển lay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Con mãi tụng ca vì Chúa ban lời bảo ban hôm sớm,
	    Dù về khuya vẫn nhủ tâm: Đặt Ngài ở trước mặt luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
	    Nay trí lòng con mừng rỡ, nên nằm nghỉ ngơi an giấc,
	    Vì Ngài đâu nỡ để con hủy diệt ở chốn mồ sâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
	    Theo lối trường sinh, ngài sẽ thương tình dạy con đưa bước,
	    Tràn niềm vui trước Thần Nhan, Gần Ngài hạnh phúc nào hơn.
    }
  >>
}

loiPhanHai = \lyricmode {
	Chúa chính là gia nghiệp và là phần phúc của con.
}

loiPhanBa = \lyricmode {
  Chúa sẽ dạy cho con biết đường lối trường sinh.
}

loiPhanBon = \lyricmode {
  Xin giữ gìn con, lạy Chúa, con tìm ẩn thân nơi Ngài.
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
  \fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t4 c /10TN: câu 1, 2, 4, 7 + Đ.3" }
        \line { \small "-t7 c /10TN: câu 1, 3, 5, 6 + Đ.1" }
        \line { \small "-t7 l /19TN: câu 1, 3, 5, 7 + Đ.1" }
        \line { \small "-Cn C /13TN: câu 1, 3, 5, 6 + Đ.1" }
        \line { \small "-t6 l /23TN: câu 1, 3, 5, 7 + Đ.1" }
        \line { \small "-Cn B /33TN: câu 4, 6, 7 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-Vọng PS: câu 4, 6, 7 + Đ.3" }
        \line { \small "-t2 PS: câu 1, 3, 5, 6, 7 + Đ.3" }
        \line { \small "-Cn /3PS: câu 1, 3, 5, 6, 7 + Đ.3" }
        \line { \small "-t5 /7PS: câu 1, 3, 5, 6, 7 + Đ.3" }
        \line { \small "-lễ chung i.Mục tử: câu 1, 3, 5, 7 + Đ.1" }
        \line { \small "-lễ chung i.Nam-Nữ: câu 1, 3, 5, 7 + Đ.1" }
        \line { \small "-cầu ơn thiên triệu: câu 1, 3, 5, 7 + Đ.1" }
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

