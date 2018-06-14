% conda.m
% a simple MATLAB utility to control conda
% environments on *nix systems
%
% usage
%
% MATLAB 			   Shell
% ===================================
% conda.getenv         conda env list
% conda.setenv(env)    source activate env
%
% Srinivas Gorur-Shandilya

classdef conda


properties
end

methods

end

methods (Static)

	function varargout = getenv()
		exe = conda.getCondaExe();
		[~, envs] = system([exe ' env list']);
		envs = strrep(envs, '*', ' ');
		envs = strsplit(envs, '\n');
		envs = regexprep(envs, '^#.*', '');
		envs = envs(~cellfun(@isempty, envs));

		p = strsplit(getenv('PATH'), pathsep);

		if ispc()
			env_bin = envs;
		else
			env_bin = cellfun(@(x) fullfile(x, 'bin'), envs, 'uniformoutput', false);
		end
		env_bin = cellfun(@(x) strsplit(x), env_bin, 'uniformoutput', false);
		active_path = find(cellfun(@(x) any(strcmp(x{2}, p)), env_bin));
		if isempty(active_path)
			% if no env has been set, then default to the base
			p = strsplit(conda.loadCondaPath(), pathsep);
			active_path = find(cellfun(@(x) any(strcmp(x{2}, p)), env_bin));
		end
		env_bin = vertcat(env_bin{:});

		if nargout
			varargout{1} = env_bin(:, 1); % env name
			varargout{2} = env_bin(:, 2); % env path
			varargout{3} = active_path;
		else
			fprintf('\n');
			env_bin{active_path, 1} = ['*' env_bin{active_path, 1}];
			for i=1:size(env_bin, 1)
				fprintf('%s\t%s\n', env_bin{i, 1}, env_bin{i, 2});
			end
		end
	end % end getenv

	function setenv(env)
		exe = conda.getCondaExe();
		[~, envs] = system([exe ' env list']);
		envs = strsplit(envs,'\n');

		[env_names, env_exe] = conda.getenv();

		% check that envs exists in the list
		assert(any(strcmp(env_names,env)), 'env you want to activate is not valid')

		p = getenv('PATH');
		% delete every conda env path from the path
		p = strsplit(p, pathsep);
		keep = true(length(p), 1);
		for i = 1:length(p)
			if any(strcmp(p{i}, env_exe))
				keep(i) = false;
			end
		end
		p = p(keep);

		% add the path of the env we want to switch to
		this_env_path = env_exe{strcmp(env_names, env)};
		p = [this_env_path p];
		p = strjoin(p, pathsep);
		setenv('PATH', p);

	end % setenv

	% this function makes sure that MATLAB knows about
	% the base Anaconda install,
	% and that "conda" can be found on the path
	function p=loadCondaPath()
		p = getenv('PATH');
		if contains(p, 'conda')
			return
		end
		if ispc()
			home_path = getenv('HOMEPATH');
		else
			home_path = getenv('HOME');
		end
		folders = dir(fullfile(home_path, '*conda*'));
		% filter for only folders
		folders = folders([folders.isdir]);
		% filter for non dot-folders
		folders = folders(~startsWith({folders.name}, '.'));
		if numel(folders) == 0
			% try base path
			folders = dir('/*conda*');
			folders = folders([folders.isdir]);
			folders = folders(~startsWith({folders.name}, '.'));
		end

		if numel(folders) == 0
			error('Could not find any anaconda folder.')
		end

		if ispc()
			p = [fullfile(folders(1).folder, folders(1).name) pathsep p];
		else
			p = [fullfile(folders(1).folder, folders(1).name, 'bin') pathsep p];
		end
   		setenv('PATH', p);

	end

	function exe=getCondaExe()
		if ispc()
			home_path = getenv('HOMEPATH');
		else
			home_path = getenv('HOME');
		end
		condas = dir(fullfile(home_path, '*conda*'));
		condas = condas(~startsWith({condas.name}, '.'));
		if ispc()
			exe = fullfile(condas(1).folder, condas(1).name, 'Library', 'bin', 'conda');
		else
			exe = fullfile(condas(1).folder, condas(1).name, 'bin', 'conda');
		end
	end


end

end % end classdef
