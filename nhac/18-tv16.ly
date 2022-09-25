% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 16"
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
  \key g \major
  \time 2/4
  \partial 8 d8 |
  b'8. b16 \tuplet 3/2 { b8 c b } |
  a4 \tuplet 3/2 { b8 g e } |
  fs4 \tuplet 3/2 { fs8 g e } |
  d4 r8 d |
  a'4 \tuplet 3/2 { a8 gs a } |
  c8. c16 \tuplet 3/2 { a8 a c } |
  d8. d,16 \tuplet 3/2 { a'8 b a } |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'8. c16 \tuplet 3/2 { b8 a b } |
      e,4 \tuplet 3/2 { e8 d8 e } |
      a4. a8 |
      g4 r8 \bar "|."
    }
    {
      g8. a16 \tuplet 3/2 { e8 d d } |
      c4 \tuplet 3/2 { c8 b a } |
      c4. c8 |
      b4 r8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4 \tuplet 3/2 { b8 g c } |
      c4. c16 d |
      fs,8 a b a
      g4 r8 \bar "|."
    }
    {
      g4 \tuplet 3/2 { g8 e e } |
      a4. e16 e |
      d8 d d c |
      b4 r8
    }
  >>
}

nhacPhanBon = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4. b16 c |
      a4. a16 a |
      d8 d c a
    }
    {
      g4. g16 a |
      c,4. e16 g |
      fs8 fs fs fs
    }
  >>
  g4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Lạy Chúa, xin minh xét cho con,
      đoái nghe lời con ai oán van nài.
      Miệng con không hề gian dối,
      mong được Ngài soi thấu, lạy Thiên Chúa công bình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Lạy Chúa xin soi ánh Thiên Nhan,
	    xét cho lòng con ngay giữa đêm trường.
	    Ngài luôn ưa điều ngay chính,
	    dẫu dùng lửa thử con, nào đâu thấy gian tà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Lạy Chúa theo chân Chúa con đi,
	    Chúa đâu để con xiêu té khi nào.
	    Này con kêu nài lên Chúa,
	    ước nguyện Ngài thương đáp vì nghe tiếng con cầu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Lạy Chúa, xin thương lắng tai nghe,
	    đáp lại lờ con tha thiết kêu nài.
	    Vì ai nương nhờ nơi Chúa,
	    Chúa dủ tình giải thoát khỏi nanh vuốt quân thù.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Phần con nương thân bóng Chúa liên,
	    sống ngay thẳng luôn,
	    nên thấy mặt Ngài.
	    Và khi con vừa tỉnh giấc
	    đã thỏa tình chiêm ngắm Thần nhan Chúa rạng ngời.
    }
  >>
}

loiPhanHai = \lyricmode {
  Phần con sống công minh chính trực
  sẽ được chiêm ngắm Thánh Nhan.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, khi vừa thức giấc, con thỏa tình chiêm ngắm Nhan Ngài.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, xin lắng tai, xin nghe rõ tiếng con kêu cầu.
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
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 l /14TN: câu 1, 2, 4, 5 + Đ.1" }
        \line { \small "-t6 c /24TN: câu 1, 4, 5 + Đ.2" }
        \line { \small "-t2 c /26TN: câu 1, 2, 4 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-CN C /32TN: câu 1, 3, 5 + Đ.2" }
        \line { \small "-t4 l /33TN: câu 1, 3, 5 + Đ.2" }
        \line { \small "-ad lib. 5MC: câu 1, 4, 5 + Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #1
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
