function template = load_template(root, animal, expdate, mode)
% root: string, path to the folder
% animal: string
% expdate: string, like 030421
% mode: 1 or 2, refering to the format of the template_path filename
% visit the folder root/animal/templatefile.mat and load the template

if mode == 1
    template_path = sprintf('%s/templates/%s_%s_template.mat', root,...
        animal, expdate);
elseif mode == 2
    template_path = sprintf('%s/templateData/%s/templateData_%s_%spix.mat', root,...
        animal, animal, expdate);
end

load(template_path, 'template');

end