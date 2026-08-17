function save_figure_to_png(fig, out_png, show_figure)
% Grafiği PNG olarak kaydeder. show_figure doğruysa ekranda da gösterir,
% yanlışsa kapar.
%
% Not: PNG üretimi qt grafik altyapısıyla (Octave GUI) sorunsuzdur.
% CLI'de (fltk) görünür pencere açmadan çizim yapılamadığından dosya
% kaydedilmez; grafikler Octave GUI'den replot_results ile çizilebilir.
% Bu durumda yalnızca bir kez uyarı verilir, pencere açılmaz.

persistent cli_warned;

toolkits = available_graphics_toolkits();
has_qt = any(strcmp(toolkits, "qt"));

saved = false;
if has_qt
    try
        print(fig, out_png, "-dpng", "-r150");
        saved = isfile(out_png);
    catch err
        warning("PNG kaydedilemedi: %s", err.message);
    end
elseif isempty(cli_warned)
    cli_warned = true;
    warning( ...
        ["CLI modunda pencere acilmadan PNG uretilemiyor; grafikler ", ...
         "atlaniyor. PNG'ler icin betigi Octave GUI'den calistirin ", ...
         "veya sonradan replot_results kullanin."]);
end

if show_figure && saved
    set(fig, "visible", "on");
else
    close(fig);
end

end
