% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 115"
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
  \partial 8
  <<
    {
      \voiceOne
      bf16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      a
    }
  >>
  bf |
  \oneVoice
  a4 \tuplet 3/2 { g8 g a } |
  f4. d16 d |
  g4 \tuplet 3/2 { a8 bf g } |
  a4 r8 c16 c |
  c4 \tuplet 3/2 { bf8 c d } |
  a4. fs16 fs |
  <<
    {
      \voiceOne
      a4
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-4
      \tweak font-size #-2
      a8.
      \tweak font-size #-2
      a16
    }
  >>
  \oneVoice
  \tuplet 3/2 { c8 d bf } |
  g4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  <<
    {
      b8 c |
      a4 \tuplet 3/2 { d8 d fs, } |
      g2 ~ |
      g4 r8 \bar "|."
    }
    {
      g8 a |
      fs4 \tuplet 3/2 { fs8 e d } |
      b2 ~ |
      b4 r8
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  <<
    {
      b8 b |
      d8. g,16 a8 b |
      e,4. e16 g |
      d8 fs a a |
      g4 r8 \bar "|."
    }
    {
      g8 g |
      fs8. e16 d8 d |
      c4. c16 c |
      b8 d c c |
      b4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  d8 d |
  g,8. g16
  <<
    {
      c8 b |
      a4 e8 e16 g |
      d8 d a' a |
      g4 r8 \bar "|."
    }
    {
      e8 g |
      d4 c8 c16 c |
      b8 b c d |
      b4 r8
    }
  >>
}

nhacPhanNam = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  b8 b16 (a) |
  g8. fs16 g8 a |
  d,4.
  <<
    {
      b'8 |
      b8. a16
    }
    {
      g8 |
      g8. c,16
    }
  >>
  <<
    {
      \voiceOne
      g'8 (fs)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      d4
    }
  >>
  \oneVoice
  <g b,>4 r8 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  g8 fs16 (g) |
  a8. d,16
  <<
    {
      g8 a |
      b4 b8 c16 c |
      a8 d fs,4 |
      g4 r8 \bar "|."
    }
    {
      b,8 d |
      g4 g8 a16 g |
      fs8 e d4 |
      b4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Vẫn vững tin khi tôi nói rằng:
      Này phận tôi muôn nỗi khổ đau.
      Tuyên ngôn khi gặp cơn hoảng sợ:
      Mọi người luôn giả dối gian tà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Vẫn vững tin khi tôi nói rằng:
      Này phận tôi muôn nỗi khổ đau.
      Nơi Ton Nhan thực đáng quý trọng
      kẻ tử \markup { \underline "vong vì" }
      trung nghĩa với Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Biết lấy chi dâng lên đáp đền
      vì hồng ân chan chứa Ngài ban.
      Tôi xin nâng này chén cứu độ
      và cầu xin danh thánh của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa thấy cho con luôn giữ trọn lời thề xưa ngay trước toàn dân.
      Nơi Tôn Nhan thực đáng quý  trọng
      kẻ tử \markup { \underline "vong vì" } trung nghĩa với Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chúa vẫn luôn tôn dương quý trọng
      người bầy tôi trung hiếu tử vong.
      Thân con dây là con nữ tỳ
      được Ngài thương cởi tháo xích xiềng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      \markup { \underline "Tôi" } tới đây thân con nũ tỳ,
      được Ngài thương cởi xích xiềng cho,
      Nay xin dâng của lễ cám tạ
      và cầu xin danh thánh của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Hiễn lễ đây dâng lên cảm tạ,
      và cầu xin danh thánh Ngài liên.
      Con ghi tâm lời xưa khấn nguyền
      và thực thi ngay trước dân Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Với Chúa đây tôi luôn giữ trọn lời thề xưa ngay trước toàn dân,
      Nơi khuôn viên đền thiêng của Ngài,
      giữa lòng \markup { \underline "người, này" } Giê -- ru -- sa -- lem.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Chúa chúng ta khoan nhân chính trực,
      Lòng Ngài ôi chan chứa tình thương.
      Luôn trông xem những ai bé mọn,
      phận hèn tôi, tay Chúa cứu độ.
    }
  >>
}

loiPhanHai = \lyricmode {
  Con sẽ dâng hiến lễ tạ ơn.
}

loiPhanBa = \lyricmode {
  Tôi nâng chén mừng ơn cứu độ và kêu cầu danh thánh Chúa liên.
}

loiPhanBon = \lyricmode {
  Biết lấy gì đền đáp Chúa đây vì mọi ơn lành Ngài đã khấng ban.
}

loiPhanNam = \lyricmode {
  Chén chúc tụng là sự thông hiệp Máu thánh Đức Ki -- tô.
}

loiPhanSau = \lyricmode {
  Trong miền đất dành cho kẻ sống, tôi sẽ bước đi trước mặt Ngài.
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
        \line { \small "-t2 c /1TN: câu 3, 4, 8 + Đ.1" }
        \line { \small "-t4 l /6TN: câu 3, 4, 8 + Đ.1" }
        \line { \small "-t6 l /10TN: câu 1, 5, 7 + Đ.1" }
        \line { \small "-t6 l /15TN: câu 3, 5, 7 + Đ.2" }
        \line { \small "-t7 c /23TN: câu 3, 7 + Đ.1" }
        \line { \small "-CN B /2MC: câu 2, 6, 8 + Đ.5" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 tuần Thánh: câu 3, 5, 7 + Đ.4" }
        \line { \small "-t7 /3PS: câu 3, 4, 6 + Đ.3" }
        \line { \small "-Mình Máu Chúa: câu 3, 5, 7 + Đ.2" }
        \line { \small "-Mình hoặc Máu Chúa (NL): câu 3, 5, 7 + Đ.2" }
        \line { \small "-Truyền chức: câu 3, 7 + Đ.4" }
        \line { \small "-Cầu hồn: câu 9, 1, 5 + Đ.5" }
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
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
    ragged-last = ##f
  }
}
