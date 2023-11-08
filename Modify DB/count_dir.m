function num_dir=count_dir(sub)
    all_files = dir(sub);
    all_dir = all_files([all_files(:).isdir]);
    num_dir = numel(all_dir)-2;
end
